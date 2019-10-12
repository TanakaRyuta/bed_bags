;;load libs
(ql:quickload '(:lispbuilder-sdl
		:cl-opengl
		:cl-glu
		:zpng
		:png-read
		;;:cl-glut
		))

(defvar *debug* nil)
(setf *debug* nil)

;;load file
(load "key.lisp" :external-format :utf-8)
(load "camera.lisp" :external-format :utf-8)
(load "loader.lisp" :external-format :utf-8)
(load "stage.lisp" :external-format :utf-8)
;;(load "status.lisp" :external-format :utf-8)
(load "objects.lisp" :external-format :utf-8)
(load "others.lisp" :external-format :utf-8)
(load "ttf.lisp" :external-format :utf-8)
(load "player.lisp" :external-format :utf-8)
(load "mouse.lisp" :external-format :utf-8)


;;window frame size
(defconstant +window-width+ 640)
(defconstant +window-height+ 480)
(defconstant +fps+ 60)

(defvar *object-num* 0)

;;entry point
(defun main ()
  (let ((cam (make-instance 'camera))
	(current-key (make-instance 'key-state))
	(frame-timer 0)
	(player (make-instance 'player))
	(mouse (make-instance 'mouse)))
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
		  :opengl-attributes '((:sdl-gl-doublebuffer 1)
				       (:SDL-GL-DEPTH-SIZE 16)
				       (:SDL-GL-STENCIL-SIZE 4)
				       (:SDL-GL-MULTISAMPLEBUFFERS 1)))
      (setf (sdl:frame-rate) +fps+)
      (sdl:show-cursor nil)
      (sdl:SDL-WM-GRAB-INPUT :sdl-grab-on)
      
      (let ((texture (car (gl:gen-textures 1)))
	    (image-data (load-texture (file-path "../texture/" "siki.png")
				      128 128 3)))
	
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;init	
	
	;;clear background
	(gl:clear-color 0 0 0 1)
	(gl:clear-stencil 0)
	
	;;set matrix-mode
	;; :modelview  -> モデルビュー行列
	;; :projection -> 射影行列
	;; :texture    -> テクスチャ行列
	(gl:matrix-mode :projection)

	;;use depth_test
	(gl:enable
	 :depth-test
	 :cull-face
	 ;;:lighting
	 ;;:light0
	 )
	
	;;init...? 
	(gl:load-identity)

	;;set game screen in window
	(gl:viewport 0 0 +window-width+ +window-height+)
	
	;;init Field of View
	(glu:perspective 30 (/ +window-width+ +window-height+) 1 100)

	(set-pos cam 20 40 0)
	(set-angle cam 0 0 0)

	(with-slots (posx posy posz anglex angley anglez) cam
	  ;;set camera position and direction of looking to
	  (glu:look-at posx posy posz
		       anglex angley anglez
		       0.0 1.0 0.0)
	  
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
	    (:mouse-motion-event (:X-REL x-rel :Y-REL y-rel)
				 ;;(format t "~a:~a:~a:~a~%" x y x-rel y-rel))
				 (set-mouse mouse
					    (parse-integer
					     (format nil "~a" x-rel))
					    (parse-integer
					     (format nil "~a" y-rel))))

	    (:idle ()
		   
		   (gl:clear :color-buffer-bit
			     :depth-buffer-bit
			     :accum-buffer-bit
			     :stencil-buffer-bit)
		   (gl:color 1 1 1)

	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   ;;mode 3d render
		   
		   (gl:matrix-mode :projection)
		   (and (> frame-timer 0) (gl:pop-matrix))
		   (gl:matrix-mode :modelview)
		   (and (> frame-timer 0) (gl:pop-matrix))
		   (gl:load-identity)
		   
		   (and (eql *debug* t) (axis 100))
		   
		   
	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   ;;player
		   (gl:push-matrix)
		   (gl:load-identity)
		   (with-slots (plposx plposy plposz pltheta) player
		     (gl:color 1 1 1)
		     (gl:translate plposx plposy plposz)
		     (face-cube 0 0 0 3)
		      
					;  (gl:rotate (* 0.05 frame-timer) 0 1 0)
		     (with-slots (right left up down sright sleft sup sdown) current-key
					;      (and right (gl:translate 0 0 10))
					;     (and left (gl:translate 0 0 -10))
					;    (and up (gl:translate 10 0 0))
					;   (and down (gl:translate -10 0 0)))
		       (and up (set_player_pos player 0 0 (+ plposz 1)))
		       (and down (set_player_pos player 0 0 (- plposz 1)))
		       (and left (set_player_pos player (+ plposx 1) 0 0))
		       (and down (set_player_pos player (- plposx 1) 0 0))))
		       
		       
		  
		   (gl:pop-matrix)
		     
		   ;;camera
		   ;;set camera pos in local
		   #|
		   (with-slots (posx posy posz anglex angley anglez) cam
		     ;;set camera position and direction of looking to
		     (set-pos cam posx 0 posz)
		     (set-angle cam 0 0 0)
		     (glu:look-at posx posy posz
				  anglex angley anglez
				  0.0 1.0 0.0))
		  ; (gl:matrix-mode :modelview)
		     |#  
		   
	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   ;;3D objects
		   (gl:load-identity)
		   (gl:push-matrix)
		 ;  (gl:load-identity)
		   (gl:enable :blend)
		   (gl:blend-func :src-alpha :one-minus-src-alpha)

		   (gl:enable :texture-2d)
		   (gl:bind-texture :texture-2d texture)
		   (gl:tex-parameter :texture-2d :texture-min-filter :nearest)
		   (gl:tex-parameter :texture-2d :texture-mag-filter :nearest)
		   (gl:tex-parameter :texture-2d :texture-border-color '(0 0 0 0))
		   (gl:tex-image-2d :texture-2d 0 :rgb
				    ;;(png-read:width image)
				    ;;(png-read:height image)
				    128 128
				    0 :rgb :unsigned-byte image-data)
		   (gl:scale (+ 1 (* 0.1 (sin (mod frame-timer 360))))
			     1
			     (+ 1 (* 0.1 (sin (mod frame-timer 360)))))
		   (gl:with-primitives :quads
		     (gl:tex-coord 0 0)
		     (gl:vertex 0 3 0)
		     (gl:tex-coord 0 1)
		     (gl:vertex 0 3 4)
		     (gl:tex-coord 1 1)
		     (gl:vertex 4 3 4)
		     (gl:tex-coord 1 0)
		     (gl:vertex 4 3 0))
		   (gl:disable :texture-2d)
		   (gl:pop-matrix)
		   
		   ;;stage
		   (gl:push-matrix)
		   (gl:load-identity)
		   (dotimes (l 4)
		     (gl:rotate 90 0 1 0)
		     (dotimes (n 15)
		       (dotimes (i 15)
			 (if (eq 0 (mod (+ (+ n 1) (+ i 1)) 2))
			     (face-frame-cube i 0 n 1 0 0 1)
			     (face-frame-cube i 0 n 1 1 1 0)))))
		   (gl:pop-matrix)

		   ;;cube
		   (gl:color 1 0 0)
		   (gl:push-matrix)
		   (gl:translate 0 2 0)
		   (gl:rotate 0 0 0 0)
		   (dotimes (i 8)
		     (gl:push-matrix)
		     (gl:rotate (* 45 i) 0 1 0)
		     (gl:translate 10 0 0)
		     (face-cube 0 0 0 1)
		     (gl:pop-matrix))
		   
		   (gl:pop-matrix)
		   
	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   ;;mode 2d render
		   (gl:matrix-mode :projection)
		   (gl:push-matrix)
		   (gl:load-identity)
		   (gl:ortho 0.0 +window-width+ +window-height+ 0.0 -1.0 1.0)
		   (gl:matrix-mode :modelview)
		   (gl:push-matrix)
		   (gl:load-identity)

	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   ;;2D objects
		   (gl:translate 140 400 0)
		   
		   
		   (gl:with-primitives :quads
		     (gl:color 0 1 0)
		     (gl:vertex 0 0 0)
		     (gl:vertex 0 50 0)
		     (gl:color 1 0 0)
		     (gl:vertex 360 50 0)
		     (gl:vertex 360 0 0))
		   
		   ;;others
		   (test-input-key current-key)

		   (gl:flush)
		   (sdl:update-display)
		   (gl:delete-textures (list texture))
		   (incf frame-timer))))))))

(main)
