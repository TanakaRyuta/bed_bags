(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)
(ql:quickload :cl-glu)
;;(ql:quickload :cl-glut)

(defvar *debug* nil)
(setf *debug* t)

;;load file
(load "key.lisp" :external-format :utf-8)
(load "camera.lisp" :external-format :utf-8)
(load "loader.lisp" :external-format :utf-8)
(load "stage.lisp" :external-format :utf-8)
;;(load "status.lisp" :external-format :utf-8)
(load "objects.lisp" :external-format :utf-8)
(load "ttf.lisp" :external-format :utf-8)

;;window frame size
(defconstant +window-width+ 640)
(defconstant +window-height+ 480)
(defconstant +fps+ 60)

(defvar *object-num* 0)

;;entry point
(defun main ()
  (let ((cam (make-instance 'camera))
	(current-key (make-instance 'key-state))
	(frame-timer 0))
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
				       (:SDL-GL-DEPTH-SIZE 16)))
      (setf (sdl:frame-rate) +fps+)
      (unless (sdl:initialise-default-font *ttf-font-msgothic*)
	(error "FONT-EXAMPLE: Cannot initialize the default font."))
      
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
       ;;:lighting
       ;;:light0
       )
      
      ;;init...? 
      (gl:load-identity)

      ;;set game screen in window
      (gl:viewport 0 0 +window-width+ +window-height+)
      

      ;;init Field of View
      (glu:perspective 30 (/ +window-width+ +window-height+) 1 100)

      ;;
      (gl:translate 0 0 0)

      (set-pos cam 50 20 50)
      (set-angle cam 0 0 0)

      (with-slots (posx posy posz anglex angley anglez) cam
	;;set camera position and direction of looking to
	(glu:look-at posx posy posz
		     anglex angley anglez
		     0.0 1.0 0.0))
      
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
	       (gl:clear :color-buffer-bit
			 :depth-buffer-bit
			 :accum-buffer-bit)
	       (gl:color 1 1 1)

	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	       ;;mode 3d render
	       (gl:matrix-mode :projection)
	       (and (> frame-timer 0) (gl:pop-matrix))
	       (gl:matrix-mode :modelview)
	       (and (> frame-timer 0) (gl:pop-matrix))
	       (gl:load-identity)

	       (and (eql *debug* t)
		    (progn
		      ;;axis
		      (gl:push-matrix)
		      (gl:color 1 0 0)
		      (gl:with-primitives :lines
			(gl:vertex -100 0 0)
			(gl:vertex 100 0 0))
		      (gl:color 0 1 0)
		      (gl:with-primitives :lines
			(gl:vertex 0 -100 0)
			(gl:vertex 0 100 0))
		      (gl:color 0 0 1)
		      (gl:with-primitives :lines
			(gl:vertex 0 0 -100)
			(gl:vertex 0 0 100))
		      (gl:pop-matrix)))
	       
	       ;;camera
	       ;;(move-angle current-key cam)
	       (gl:rotate frame-timer 0.0 1.0 0.0)
	       (gl:rotate 0 1.0 0.0 0.0)
	       (gl:rotate 0 0.0 0.0 1.0)
	       (gl:translate 0 0 0)

	       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	       ;;3D objects
	       ;;(gl:push-matrix)
	       (dotimes (n 15)
		 (dotimes (i 15)
		   (if (eq 0 (mod (+ (+ n 1) (+ i 1)) 2))
		       (face-frame-cube i 0 n 1 1 0 0)
		       (face-frame-cube i 0 n 1 0 1 0))))
	       ;;(gl:pop-matrix)

	       ;;(gl:push-matrix)
	       (gl:load-identity)
	       (gl:rotate 45 0 1 0)
	       (face-frame-cube
		1 1 1
		2
		0 0 1)
	       ;;(gl:pop-matrix)

	       ;;cube
	       (gl:push-matrix)
	       (gl:translate (mod frame-timer 100) 0 0)
	       (face-frame-cube 10 0 0 2 1 1 1)
	       (face-frame-cube 0 10 0 2 1 1 1)
	       (face-frame-cube 0 0 10 2 1 1 1)
	       (face-frame-cube -10 0 0 2 1 1 1)
	       (face-frame-cube 0 -10 0 2 1 1 1)
	       (face-frame-cube 0 0 -10 2 1 1 1)
	       (gl:pop-matrix)
	       
	       ;;mode 2d render
	       (gl:matrix-mode :projection)
	       (gl:push-matrix)
	       (gl:load-identity)
	       (gl:ortho 0.0 +window-width+ +window-height+ 0.0 -1.0 1.0)
	       (gl:matrix-mode :modelview)
	       (gl:push-matrix)
	       (gl:load-identity)

	       (gl:translate 140 400 0)
	       (gl:translate (* 2 (mod frame-timer 180)) 0 0)
	       (gl:rotate (mod frame-timer 360) 0.0 0.0 1.0)

	       (gl:with-primitives :quads
		 (gl:color 0 1 0)
		 (gl:vertex 0 0 0)
		 (gl:vertex 0 50 0)
		 (gl:color 1 0 0)
		 (gl:vertex 360 50 0)
		 (gl:vertex 360 0 0))
	       
	       (sdl:draw-string-solid-* "Text UTF8 - Solid" 10 0
					:color sdl:*white*)
	       (sdl:draw-string-shaded-* "Text UTF8 - Shaded 日本語テスト" 0 32
					 sdl:*black*
					 sdl:*yellow*)

	       (test-input-key current-key)

	       (gl:flush)
	       (sdl:update-display)
	       (setf frame-timer (+ 1 frame-timer)))))))

(main)
