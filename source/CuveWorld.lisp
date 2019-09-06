(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)
(ql:quickload :cl-glu)
;;(ql:quickload :cl-glut)

;;load file
(load "key.lisp" :external-format :utf-8)
(load "camera.lisp" :external-format :utf-8)
(load "loader.lisp" :external-format :utf-8)
(load "stage.lisp" :external-format :utf-8)
;;(load "status.lisp" :external-format :utf-8)
(load "objects.lisp" :external-format :utf-8)

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
      (gl:translate 0 0 0)

      (set-pos cam -20 -20 20)
      (set-angle cam 0 0 0)

      (with-slots (posx posy posz anglex angley anglez) cam
	;;set camera position and direction of looking to
	(glu:look-at posx posy posz
		     anglex angley anglez
		     0.0 0.0 1.0))
      
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

	       ;;mode 3d render
	       (gl:matrix-mode :projection)
	       (and (> frame-timer 0) (gl:pop-matrix))
	       (gl:matrix-mode :modelview)
	       (and (> frame-timer 0) (gl:pop-matrix))
	       (gl:load-identity)
	       
	       (move-angle current-key cam)

	       (dotimes (n 15)
		 (dotimes (i 15)
		   (if (eq 0 (mod (+ (+ n 1) (+ i 1)) 2))
		       (face-frame-cube i n 0 1 1 0 0)
		       (face-frame-cube i n 0 1 0 1 0))))

	       (gl:push-matrix)
	       
	       (face-frame-cube
		1 1 1
		2
		0 0 1)
	       (gl:pop-matrix)

	       ;;axis
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

	       ;;mode 2d render
	       (gl:matrix-mode :projection)
	       (gl:push-matrix)
	       (gl:load-identity)
	       (gl:ortho 0.0 +window-width+ +window-height+ 0.0 -1.0 1.0)
	       (gl:matrix-mode :modelview)
	       (gl:push-matrix)
	       (gl:load-identity)

	       (gl:with-primitives :quads
		 (gl:color 0 1 0)
		 (gl:vertex 140 400 0)
		 (gl:vertex 140 450 0)
		 (gl:color 1 0 0)
		 (gl:vertex 500 450 0)
		 (gl:vertex 500 400 0))

	       (test-input-key current-key)

	       (sdl:update-display)
	       (setf frame-timer (+ 1 frame-timer)))))))

(main)
