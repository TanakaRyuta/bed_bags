(ql:quickload '(:cl-opengl
		:cl-glu
		:cl-glut
		:classimp
		:cl-devil
		:sb-cga
		:cl-ilut
		))

(defclass ai-sample3-model ()
  ((file :accessor file :initarg :file)
   (scene :accessor scene :initarg :scene)
   (bounds-min :accessor bounds-min)
   (bounds-max :accessor bounds-max)
   (scene-center :accessor scene-center :initform #(0.0 0.0 0.0))
   (scene-scale :accessor scene-scale :initform 1.0)
   (angle :accessor angle :initform 0.0)))

(defun scene-bounds (scene)
  (let ((min (sb-cga:vec 1f10 1f10 1f10))
        (max (sb-cga:vec -1f10 -1f10 -1f10)))
    (labels ((mesh-bounds (mesh xform)
               (loop for vertex across (ai:vertices mesh)
                  for transformed = (sb-cga:transform-point
                                     vertex
                                     (sb-cga:transpose-matrix xform))
                  do (setf min (sb-cga:vec-min min transformed)
                           max (sb-cga:vec-max max transformed))))
	     (node-bounds (node xform)
	       (let ((transform (sb-cga:matrix* (ai:transform node) xform)))
		 (loop for i across (ai:meshes node)
		    do (mesh-bounds (aref (ai:meshes scene) i) transform))
		 (loop for i across (ai:children node)
		    do (node-bounds i transform)))))
      (node-bounds (ai:root-node scene) (sb-cga:identity-matrix)))
    (values min max)))

(defmethod update-bounds ((model ai-sample3-model))
  (setf (values (bounds-min model) (bounds-max model))
        (scene-bounds (scene model)))
  (let* ((min (bounds-min model))
         (max (bounds-max model))
         (d (sb-cga:vec- max min))
         (s (/ 1.0 (max (aref d 0) (aref d 1) (aref d 2))))
         (c (sb-cga:vec/ (sb-cga:vec+ min max) 2.0)))
    (format t "bounds = ~s - ~s~%, s=~s c=~s~%" min max s c)
    (setf (scene-scale model) (* 0.95 s))
    (setf (scene-center model) c)))

(defparameter *flip-yz* nil)
(defparameter *use-lights* t)
(defparameter *invert-texture-v* nil)
(defparameter *invert-normals* nil)
(defparameter *tris* 0)
(defparameter *spin* t)
(defparameter *anim-speed* 0.8)
(defparameter *wire* t)
(defparameter *dump* nil)

(defparameter *bone-transforms* nil)
(defparameter *node-transforms* nil)
(defparameter *current-bone-transform* sb-cga:+identity-matrix+)

(defparameter *filename* nil)

(defun quat->matrix (q)
  (let ((w (- (aref q 0)))
        (x (aref q 1))
        (y (aref q 2))
        (z (aref q 3)))
    (declare (single-float w x y z))
    (sb-cga:matrix
     (- 1.0 (* 2.0 (+ (expt y 2) (expt z 2))))
     (* 2.0 (+ (* x y) (* z w)))
     (* 2.0 (- (* x z) (* y w)))
     0.0

     (* 2.0 (- (* x y) (* z w)))
     (- 1.0 (* 2.0 (+ (expt x 2) (expt z 2))))
     (* 2.0 (+ (* y z) (* x w)))
     0.0

     (* 2.0 (+ (* x z) (* y w)))
     (* 2.0 (- (* y z) (* x w)))
     (- 1.0 (* 2.0 (+ (expt x 2) (expt y 2))))
     0.0

     0.0 0.0 0.0 1.0)))

(defun nqlerp (a b f)
  (let ((f2 (- 1.0 f)))
    ;; make sure we get shortest path between orientations
    ;; (if (a dot b) < 0, negate b)
    (let ((d (+ (* (aref a 0) (aref b 0))
                (* (aref a 1) (aref b 1))
                (* (aref a 2) (aref b 2))
                (* (aref a 3) (aref b 3)))))
      (when (< d 0)
        (map-into b #'- b)))
    (macrolet ((dim (n)
                 `(+ (* f2 (aref a ,n)) (* f (aref b ,n)))))
      (let* ((r0 (dim 0))
             (r1 (dim 1))
             (r2 (dim 2))
             (r3 (dim 3))
             (l (sqrt (+ (expt r0 2) (expt r1 2) (expt r2 2) (expt r3 2)))))
        (make-array 4 :element-type 'single-float
                    :initial-contents (list (float (/ r0 l) 1f0)
                                            (float (/ r1 l) 1f0)
                                            (float (/ r2 l) 1f0)
                                            (float (/ r3 l) 1f0)))))))

(defmethod animate-bones ((model ai-sample3-model))
  ;; update node transform (probably should just do this one at load)
  (labels ((nx (n pm)
             (let* ((m (ai:transform n))
                    (pm (sb-cga:matrix* m pm)))
               (setf (gethash (ai:name n) *node-transforms*) pm)
               (setf (gethash (ai:name n) *bone-transforms*) sb-cga:+identity-matrix+)
               (loop for child across (ai:children n)
                  do (nx child pm)))))
    (nx (ai:root-node (scene model)) (sb-cga:identity-matrix)))

  (unless (zerop (length (ai:animations (scene model))))
    (loop
       with anims = (ai:animations (scene model))
       with a = (unless (zerop (length anims)) (aref anims 0))
       with time = (if (and a (not (zerop (ai:duration a))))
		       (mod (* *anim-speed*
			       (/ (get-internal-real-time)
				  (float internal-time-units-per-second 1f0)))
			    (ai:duration a))
		       0.0)
       for na across (ai:channels a)
       do
       ;; fixme: something should check for anims with no keys at all,
       ;; not sure if that should be here or if we should just drop the
       ;; whole node-anim in translators?
       ;; fixme: clean up interpolation stuff, cache current keyframe, etc
	 (let ((r (ai:value (aref (ai:rotation-keys na) 0)))
	       (s (aref (ai:scaling-keys na) 0))
	       (x (ai:value (aref (ai:position-keys na) 0))))
	   (loop
	      for i across (ai:rotation-keys na)
	      for j from -1
	      until (> (ai:key-time i) time)
	      do (setf r (ai:value i))
	      finally (when (and (>= j 0) (> (ai:key-time i) time))
			(let ((prev (aref (ai:rotation-keys na) j)))
			  (setf r (nqlerp (ai:value prev) (ai:value i)
					  (/ (- time (ai:key-time prev))
					     (- (ai:key-time i)
						(ai:key-time prev))))))))
	   (loop for i across (ai:scaling-keys na)
	      while (<= (ai:key-time i) time)
	      do (setf s i))
	   (loop for i across (ai:position-keys na)
	      for j from -1
	      while (<= (ai:key-time i) time)
	      do (setf x (ai:value i))
	      finally (when (and (>= j 0) (> (ai:key-time i) time))
			(let* ((prev (aref (ai:position-keys na) j))
			       (dt (float
				    (/ (- time (ai:key-time prev))
				       (- (ai:key-time i) (ai:key-time prev)))
				    1f0)))
			  (setf x (sb-cga:vec-lerp (ai:value prev) (ai:value i) dt)))))
	   (setf (gethash (ai:node-name na) *bone-transforms*)
		 (sb-cga:matrix* (sb-cga:translate x)
				 (quat->matrix r)
				 (sb-cga:scale (ai:value s)))))))
  (labels ((ax (n)
             (let* ((m (or (gethash (ai:name n) *bone-transforms*)
                           (gethash (ai:name n) *node-transforms*)))
                    (*current-bone-transform*
                     (sb-cga:matrix* *current-bone-transform* m)))
               (setf (gethash (ai:name n) *bone-transforms*)
                     (if (zerop (length (ai:animations (scene model))))
                         (sb-cga:transpose-matrix
                          (gethash (ai:name n) *node-transforms*))
			 *current-bone-transform*))
               (loop for child across (ai:children n)
                  do (ax child)))))
    (ax (ai:root-node (scene model)))))

(defmethod set-up-material ((model ai-sample3-model) material)
  (flet ((material (param value)
           (when value
             (when (eq param :shininess)
               (setf value (max 0.0 (min 128.0 value))))
             (if (or (numberp value) (= (length value) 4))
                 (gl:material :front param value)
                 (gl:material :front param (map-into (vector 1.0 1.0 1.0 1.0) #'identity value)))
             (when (eq param :diffuse)
               (if (= (length value) 3)
                   (gl:color (aref value 0) (aref value 1) (aref value 2))
                   (gl:color (aref value 0) (aref value 1) (aref value 2) (aref value 3)))))))
    (material :ambient (gethash "$clr.ambient" material))
    (material :diffuse (gethash "$clr.diffuse" material))
    (material :specular (gethash "$clr.specular" material))
    (material :emission (gethash "$clr.emissive" material))
    (material :shininess (gethash "$mat.shininess" material))
    (material :emission (gethash "$clr.emissive" material))
    ;; for gourad shading or 0.0 shininess, turn off specular
    (when (or (eq :ai-shading-mode-gouraud (gethash "$mat.shadingm" material))
              (not (gethash "$mat.shininess" material))
              (zerop (gethash "$mat.shininess" material)))
      (gl:material :front :specular (vector 0.0 0.0 0.0 1.0)))
    (let* ((tex (gethash "$tex.file" material))
           (tex-name (getf (cdddr (assoc :ai-texture-type-diffuse tex))
                           :texture-name)))
      (when *dump* (format t "tex = ~s / ~s~%" tex tex-name))
      (if tex-name
          (progn
            (gl:enable :texture-2d)
            (gl:bind-texture :texture-2d tex-name)
            (let ((uvx (car (gethash "$tex.uvtrafo" material))))
              (gl:matrix-mode :texture)
              (gl:load-identity)
              (when *invert-texture-v* (gl:scale 1.0 -1.0 1.0))
              (when uvx
                ;; not sure about order of these...
                (destructuring-bind (type index (x s r)) uvx
                  (declare (ignore type index))
                  (gl:translate (aref x 0) (aref x 1) 0.0)
                  (gl:scale (aref s 0) (aref s 1) 1.0)
                  (gl:translate 0.5 0.5 0.0)
                  (gl:rotate (- (* (/ 180 pi) r)) 0.0 0.0 1.0)
                  (gl:translate -0.5 -0.5 0.0)))
              (gl:matrix-mode :modelview)))
          (gl:disable :texture-2d)))))

(defmethod recursive-render3 ((model ai-sample3-model))
  (labels
      ((r (scene node)
         (gl:with-pushed-matrix
	   (loop
	      with node-meshes = (ai:meshes node)
	      with scene-meshes = (ai:meshes scene)
	      for mesh-index across node-meshes
	      for mesh = (aref scene-meshes mesh-index)
	      for faces = (ai:faces mesh)
	      for vertices = (ai:vertices mesh)
	      for bones = (ai:bones mesh)
	      for normals = (ai:normals mesh)
	      when bones
	      do (loop
		    with skinned-vertices = (map-into
					     (make-array (length vertices))
					     (lambda ()
					       (sb-cga:vec 0.0 0.0 0.0)))
		    for bone across bones
		    for ofs = (ai:offset-matrix bone)
		    for bx = (gethash (ai:name bone) *bone-transforms*)
		    for mm = (if (and ofs bx)
				 (sb-cga:matrix* bx (sb-cga:transpose-matrix ofs))
				 (or ofs bx))
		    do (when mm
			 (loop for w across (ai:weights bone)
			    for id = (ai:id model)
			    for weight = (ai:weight model)
			    do
			      (setf (aref skinned-vertices id)
				    (sb-cga:vec+ (aref skinned-vertices id)
						 (sb-cga:vec*
						  (sb-cga:transform-point
						   (aref vertices id)
						   mm)
						  weight)))))
		    finally (setf vertices skinned-vertices))
	      do
		(gl:material :front :ambient #(0.2 0.2 0.2 1.0))
		(gl:material :front :diffuse #(0.8 0.8 0.8 1.0))
		(gl:material :front :emission #(0.0 0.0 0.0 1.0))
		(gl:material :front :specular #(1.0 0.0 0.0 1.0))
		(gl:material :front :shininess 15.0)
		(gl:color 1.0 1.0 1.0 1.0)
		(when (ai:material-index mesh)
		  (set-up-material model (aref (ai:materials scene)
					       (ai:material-index mesh))))
		(gl:with-pushed-matrix
		  (unless bones
		    (gl:mult-matrix (gethash (ai:name node) *node-transforms* )))
		  (gl:with-primitives
		      (cond
			((ai:mesh-has-multiple-primitive-types mesh)
			 (when *dump*
			   (format t "multiple primitive types in mesh?"))
			 (setf normals nil)
			 :points)
			((ai:mesh-has-points mesh) (setf normals nil) :points)
			((ai:mesh-has-lines mesh) (setf normals nil) :lines)
			((ai:mesh-has-triangles mesh) :triangles)
			((ai:mesh-has-polygons mesh) :polygons))
		    (loop
		       for face across faces
		       do
			 (incf *tris*)
			 (loop
			    for i across face
			    for v = (aref vertices i)
			    do
			      (when normals
				(let ((n (sb-cga:vec* (sb-cga:normalize
						       (aref (ai:normals mesh) i))
						      (if *invert-normals* -1.0 1.0))))
				  (gl:normal (aref n 0) (aref n 1) (aref n 2))))
			      (when (and (ai:colors mesh)
					 (> (length (ai:colors mesh)) 0))
				(let ((c (aref (ai:colors mesh) 0)))
				  (when (setf c (aref c i)))
				  (when c (gl:color (aref c 0)
						    (aref c 1)
						    (aref c 2)))))
			      (when (and (ai:texture-coords mesh)
					 (> (length (ai:texture-coords mesh)) 0))
				(let ((tc (aref (ai:texture-coords mesh) 0)))
				  (when tc
				    (gl:tex-coord (aref (aref tc i) 0)
						  (aref (aref tc i) 1)
						  (aref (aref tc i) 2)))))
			      (gl:vertex (aref v 0) (aref v 1) (aref v 2)))))))
	   (loop for child across (ai:children node)
	      do (r scene child)))))
    (r (scene model) (ai:root-node (scene model)))))

(defmethod recursive-render2 ((w ai-sample3-model))
  (labels
      ((r (scene node)
         (gl:with-pushed-matrix
           (when (gethash (ai:name node) *node-transforms*)
             (gl:with-pushed-matrix
               (gl:mult-transpose-matrix (gethash (ai:name node) *node-transforms*))
               (gl:color 0.5 0.4 1.0 1.0)))
           (when (gethash (ai:name node) *bone-transforms*)
             (gl:with-pushed-matrix
               (gl:mult-matrix (gethash (ai:name node) *bone-transforms*))
               (gl:color 1.5 0.4 0.0 1.0)))
           (loop
              with node-meshes = (ai:meshes node)
              with scene-meshes = (ai:meshes scene)
              for mesh-index across node-meshes
              for mesh = (aref scene-meshes mesh-index)
              for faces = (ai:faces mesh)
              for vertices = (ai:vertices mesh)
              for bones = (ai:bones mesh)
              when bones
              do (loop
                    with skinned-vertices = (map-into (make-array (length vertices))
                                                      (lambda ()
                                                        (sb-cga:vec 0.0 0.0 0.0)))
                    with weight-totals = (make-array (length vertices) :initial-element 0.0)
                    with weight-counts = (make-array (length vertices) :initial-element 0)
                    for bone across bones
                    for ofs = (ai:offset-matrix bone)
                    for bx = (gethash (ai:name bone) *bone-transforms*)
                    for nx = (gethash (ai:name bone) *node-transforms*)
                    for mm = (if (and ofs bx)
                                 (sb-cga:matrix* bx
                                                 (sb-cga:transpose-matrix ofs))
                                 (or ofs bx))
                    do (when mm
                         (loop for w across (ai:weights bone)
                            for id = (ai:id w)
                            for weight = (ai:weight w)
                            do
			      (incf (aref weight-counts id))
			      (incf (aref weight-totals id) weight)
			      (setf (aref skinned-vertices id)
				    (sb-cga:vec+ (aref skinned-vertices id)
						 (sb-cga:vec*
						  (sb-cga:transform-point
						   (aref vertices id)
						   mm)
						  weight)))))
                    finally (setf vertices skinned-vertices))
              do (gl:with-pushed-matrix
                   (unless bones
                     (gl:mult-matrix (gethash (ai:name node) *bone-transforms*)))
                   (gl:with-primitives :triangles
                     (gl:color 0.0 1.0 0.0 1.0)
                     (loop
                        for face across faces
                        do
			  (incf *tris*)
			  (loop
			     for i across face
			     for v = (aref vertices i)
			     do
			       (when (ai:normals mesh)
				 (let ((n (sb-cga:normalize (aref (ai:normals mesh) i))))
				   (gl:normal (aref n 0) (aref n 1) (aref n 2))))
			       (gl:vertex (aref v 0) (aref v 1) (aref v 2)))))))
           (loop for child across (ai:children node)
              do (r scene child)))))
    (r (scene w) (ai:root-node (scene w)))))

(defun spin ()
  (float (* 50 (/ (get-internal-real-time)
                  (float internal-time-units-per-second)))))

(defun unload-textures (window)
  (when (and window (scene window))
    (format t "  cleaning up materials~%")
    (loop for i across (ai:materials (scene window))
       for tex.file = (gethash "$tex.file" i)
       do (loop for f in tex.file
             for tex = (getf (cdddr f) :texture-name)
             do (format t "cleaning up old texture ~s~%" f)
             when tex
             do (format t "deleting old texture name ~s~%" tex)
               (gl:delete-textures (list tex))))))

(defun reload-textures (window &optional (clean-up t))
  (when clean-up (unload-textures window))
  (loop for i across (ai:materials (scene window))
     for tex.file = (gethash "$tex.file" i)
     do (loop for tf in tex.file
           for (semantic index file) = tf
           if (and (plusp (length file))
                   (char= #\* (char file 0))) ;; embedded file
           do (let ((tex-index (parse-integer (subseq file 1) :junk-allowed t)))
                (if (or (not tex-index) (not (numberp tex-index))
                        (minusp tex-index)
                        (>= tex-index (length (ai:textures (scene window)))))
                    (format t "bad embedded texture index ~s (~s)~%"
                            tex-index (subseq file 1))
                    (destructuring-bind (type w h data &optional format-hint)
                        (aref (ai:textures (scene window)) tex-index )
                      (declare (ignorable format-hint))
                      (if (eq type :bgra)
                          (let ((name (car (gl:gen-textures 1))))
                            (format t "load embedded texture ~s x ~s~%" w h)
                            (gl:bind-texture :texture-2d name)
                            (gl:tex-parameter :texture-2d :texture-min-filter
                                              :linear)
                            (gl:tex-parameter :texture-2d :generate-mipmap t)
                            (gl:tex-parameter :texture-2d :texture-min-filter
                                              :linear-mipmap-linear)
                            (gl:tex-image-2d :texture-2d 0 :rgba w h
                                             0 :bgra :unsigned-byte
                                             data)
                            (setf (getf (cdddr tf) :texture-name) name))
                          (let ((iname (il:gen-image))
                                (result nil))
                            (il:with-bound-image iname
                              (cffi:with-pointer-to-vector-data (p data)
                                (il:load-l :unknown p (length data) ))
                              (setf result (ilut:gl-bind-tex-image)))
                            (il:delete-images (list iname))
                            (setf (getf (cdddr tf) :texture-name) result))))))
           else if (find #\* file) ;; texture name with * in it?
           do (format t "bad texture name ~s~%" file)
           else ;; external texture
           do (let* ((cleaned (substitute
                               #\/ #\\
                               (string-trim #(#\space #\Newline
                                              #\Return #\tab)
					    file)))
                     (final-path cleaned))
                ;; some model formats store absolute paths, so
                ;; let's try chopping dirs off the front if we
                ;; can't find it directly
                (loop named outer
                   with (car . d) = (pathname-directory (truename *filename*))
                   for base on (reverse d)
                   for base-path = (make-pathname :directory (cons car (reverse base)))
                   ;;do (format t "base dir ~s~%" base-path)
                   when (probe-file (merge-pathnames cleaned base-path))
                   return  (setf final-path
                                 (cffi-sys:native-namestring
                                  (merge-pathnames cleaned base-path)))
                   do (flet ((relative (f)
                               (cffi-sys:native-namestring
                                (merge-pathnames f base-path))))
                        (loop for offset = 0 then (position #\/ cleaned :start (1+ offset))
                           while offset
                           when (probe-file (relative (subseq cleaned (1+ offset))))
                           do (return-from outer (setf final-path
						       (relative (subseq cleaned
									 (1+ offset))))))))
                (format t "load texture file ~s from ~s~%" file
                        final-path)
                (setf (getf (cdddr tf) :texture-name)
                      (ilut:gl-load-image final-path))))))

(defun reload-scene (&optional window)
  (when *filename*
    (format t "reload scene -> ~s~%" *filename*)
    (let ((s (ai:import-into-lisp
              (cffi-sys:native-namestring (truename *filename*))
              :processing-flags '(:ai-process-validate-data-structure
                                  :ai-process-preset-target-realtime-quality))))
      (when (and window s)
        (unload-textures window)
        (setf (scene window) s)
        (format t "  set bounds~%")
        (update-bounds window)
        (format t "  load materials~%")
        (reload-textures window nil))
      (if s
          (format t "loaded ~s~%" *filename*)
          (format t "failed to load ~s~%" *filename*))
      s)))

(defmethod xform ((model ai-sample3-model))
  (unless (and *use-lights* (ai:lights (scene model)))
    (when *dump* (format t "activate default light~%"))
    (gl:disable :light1 :light2 :light3 :light4 :light5 :light6 :light7)
    (gl:enable :light0)
    (gl:light :light0 :position '(10.0 7.0 5.0 0.0))
    (gl:light :light0 :ambient '(0.0 0.0 0.0 1.0))
    (gl:light :light0 :diffuse '(0.8 0.8 0.8 1.0))
    (gl:light :light0 :specular '(0.0 0.0 1.0 1.0))
    (gl:light :light0 :spot-cutoff 180.0)))

(defun ai-sample3 (&optional (file))
  (when file
    (format t "loading ~s (~s) ~%" file (probe-file file))
    (ai:with-log-to-stdout ()
      (let* ((*filename*  (namestring (truename file)))
	     (scene (reload-scene)))
	(when scene (make-instance 'ai-sample3-model
				   :scene scene))
	scene))))

(defmethod model-render ((model ai-sample3-model) &key (x 0) (y 0) (z 0) (r 1) (mode 2))
  (gl:push-matrix)
  (gl:translate x y z)
  (gl:scale r r r)
  (when (and (slot-boundp model 'scene)
             (scene model))
    (xform model)
    (let ((*tris* 0))      
      (let ((*bone-transforms* (make-hash-table :test 'equal))
            (*node-transforms* (make-hash-table :test 'equal)))
        (with-simple-restart (continue "continue")
          (animate-bones model)
	  (if (eql mode 2)
	      (recursive-render2 model)
	      (recursive-render3 model))))
      (when *dump*
        (setf *dump* nil)
        (format t "scene lights are ~s~%" (if (ai:lights (scene model))
                                              (if *use-lights* "active"
                                                  "disabled")
                                              "unavailable"))
        (format t "drew ~s tris~%" *tris*))))
  (gl:pop-matrix))

(defmethod model-init ((model ai-sample3-model))
  (update-bounds model)
  (reload-textures model))

(defun il-init ()
  (il:init)
  (ilut:init)
  (ilut:renderer :opengl)
  (ilut:enable :opengl-conv))
