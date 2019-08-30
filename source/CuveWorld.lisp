(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)
(ql:quickload :cl-glu)
;;(ql:quickload :cl-glut)

;;load file
(load "key.lisp" :external-format :utf-8)
(load "loader.lisp" :external-format :utf-8)
(load "stage.lisp" :external-format :utf-8)
;;(load "status.lisp" :external-format :utf-8)
(load "objects.lisp" :external-format :utf-8)

;;window frame size
(defconstant +window-width+ 640)
(defconstant +window-height+ 480)
(defconstant +fps+ 60)

(defvar *object-num* 0)


;;
(defstruct camera
  (posx 0)
  (posy 0)
  (posz 0)
  (dirx 0)
  (diry 0)
  (dirz 0))

(defun camera-pos (camera x y z)
  (setf (camera-posx camera) x)
  (setf (camera-posy camera) y)
  (setf (camera-posz camera) z))

(defun camera-dir (camera x y z)
  (setf (camera-dirx camera) x)
  (setf (camera-diry camera) y)
  (setf (camera-dirz camera) z)
  )

;;
(defun frame-cube (x y z r)  
  (+ *object-num* 1)
  (gl:with-primitives :lines
    (gl:vertex x y z)
    (gl:vertex (+ x r) y z))
  (gl:with-primitives :lines
    (gl:vertex x y z)
    (gl:vertex x (+ y r) z))
  (gl:with-primitives :lines
    (gl:vertex x y z)
    (gl:vertex x y (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex (+ x r) y z)
    (gl:vertex (+ x r) (+ y r) z))
  (gl:with-primitives :lines
    (gl:vertex (+ x r) y z)
    (gl:vertex (+ x r) y (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex x (+ y r) z)
    (gl:vertex (+ x r) (+ y r) z))
  (gl:with-primitives :lines
    (gl:vertex x (+ y r) z)
    (gl:vertex x (+ y r) (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex x y (+ z r))
    (gl:vertex (+ x r) y (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex x y (+ z r))
    (gl:vertex x (+ y r) (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex (+ x r) (+ y r) z)
    (gl:vertex (+ x r) (+ y r) (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex (+ x r) y (+ z r))
    (gl:vertex (+ x r) (+ y r) (+ z r)))
  (gl:with-primitives :lines
    (gl:vertex x (+ y r) (+ z r))
    (gl:vertex (+ x r) (+ y r) (+ z r))))

(defun face-cube (x y z r)
  (+ *object-num* 1)
  (gl:with-primitives :quads
    (gl:vertex x (+ y r) z) (gl:vertex (+ x r) (+ y r) z)
    (gl:vertex (+ x r) y z) (gl:vertex x y z))
  (gl:with-primitives :quads
    (gl:vertex x y z) (gl:vertex (+ x r) y z)
    (gl:vertex (+ x r) y (+ z r)) (gl:vertex x y (+ z r)))
  (gl:with-primitives :quads
    (gl:vertex x y z) (gl:vertex x y (+ z r))
    (gl:vertex x (+ y r) (+ z r)) (gl:vertex x (+ y r) z))
  (gl:with-primitives :quads
    (gl:vertex x y (+ z r))(gl:vertex (+ x r) y (+ z r))
    (gl:vertex (+ x r) (+ y r) (+ z r)) (gl:vertex x (+ y r) (+ z r)))
  (gl:with-primitives :quads
    (gl:vertex x (+ y r) z) (gl:vertex x (+ y r) (+ z r))
    (gl:vertex (+ x r) (+ y r) (+ z r)) (gl:vertex (+ x r) (+ y r) z))
  (gl:with-primitives :quads
    (gl:vertex (+ x r) y z) (gl:vertex (+ x r) (+ y r) z)
    (gl:vertex (+ x r) (+ y r) (+ z r)) (gl:vertex (+ x r) y (+ z r)))
  )

;;entry point
(defun main ()
  (let ((cam (make-camera :posx 0 :posy 0 :posz 0
			  :dirx 0 :diry 0 :dirz 0))
	(current-key (make-instance 'key-state)))
    (sdl:with-init ()

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;window
      
      ;;window option
      (sdl:window +window-width+ +window-height+
		  :title-caption "タイトル"
		  :icon-caption "title"
		  ;;:fullscreen
		  ;;:no-frame
		  :opengl t
		  :opengl-attributes '((:sdl-gl-doublebuffer 1)))
      (setf (sdl:frame-rate) +fps+)
      
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;init
      
      ;;clear background
      (gl:clear-color 0 0 0 0)
      
      ;;set matrix-mode
      ;; :modelview  -> モデルビュー行列
      ;; :projection -> 射影行列
      ;; :texture    -> テクスチャ行列
      (gl:matrix-mode :projection)

      ;;use depth_test
      (gl:enable
       :depth-test
       :cull-face
       )
      
      ;;init...? 
      (gl:load-identity)

      ;;set game screen in window
      (gl:viewport 0 0 +window-width+ +window-height+)

      ;;init Field of View
      (glu:perspective 30 (/ +window-width+ +window-height+) 1 100)

      ;;
      (gl:translate 0 0 -5)

      (camera-pos cam -20 -20 20)
      
      ;;set camera position and direction of looking to
      (glu:look-at (camera-posx cam) (camera-posy cam) (camera-posz cam)
		   (camera-dirx cam) (camera-diry cam) (camera-dirz cam)
		   0.0 0.0 1.0)
      
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;game loop
      
      (sdl:with-events ()
	(:quit-event () t)
	(:key-down-event (:key key)
			 (if (sdl:key= key :sdl-key-escape)
			     (sdl:push-quit-event)
			     (set-key-state key t current-key)))
	(:key-up-event (:key key)
		       (set-key-state key nil current-key))
	(:idle ()
	       (gl:clear :color-buffer-bit :depth-buffer-bit)
	       (gl:color 1 1 1)

	       (dotimes (n 99)
		 (dotimes (i 99)
		   (if (eq 0 (mod (+ (+ n 1) (+ i 1)) 2))
		       (gl:color 1 0 0)
		       (gl:color 0 1 0))
		   (face-cube i n 0 1)))
	       
	       (gl:color 0 0 1)
	       (face-cube 0 0 1 1)

	       (test-input-key current-key)
	       
	       (sdl:update-display))))))

(main)
