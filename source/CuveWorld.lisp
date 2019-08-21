(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)
(ql:quickload :cl-glu)

;;window frame size
(defconstant +window-width+ 640)
(defconstant +window-height+ 480)

(defun main ()
  (sdl:with-init ()

    ;;window option
    (sdl:window +window-width+ +window-height+
		:title-caption "タイトル"
		:icon-caption "title"
		;;:fullscreen
		;;:no-frame
		:opengl t
		:opengl-attributes '((:sdl-gl-doublebuffer 1)))

    ;;clear background
    (gl:clear-color 0 0 0 0)
    
    ;;set matrix-mode
    ;; :modelview  -> モデルビュー行列
    ;; :projection -> 射影行列
    ;; :texture    -> テクスチャ行列
    (gl:matrix-mode :projection)

    ;;init... 
    (gl:load-identity)

    (gl:viewport 0 0 +window-width+ +window-height+)

    ;;正射影用設定
    ;;(gl:ortho 0 1 0 1 -1 1)

    ;;遠近あり
    (glu:perspective 30 (/ +window-width+ +window-height+) 1 100)

    ;;set camera position
    (gl:translate 0 0 -5)
    ;;look-at
    (glu:look-at 3.0 4.0 5.0 0.0 0.0 0.0 1.0 0.0 0.0)
    
    (sdl:with-events ()
      (:quit-event () t)
      (:key-down-event (:key key)
		       (when (sdl:key= key :sdl-key-escape)
			 (sdl:push-quit-event)))
      (:idle ()
	     (gl:clear :color-buffer-bit)
	     (gl:color 0 0 1)
	     (gl:with-primitives :lines
	       (gl:vertex 0 0 0)
	       (gl:vertex 1 0 0))
	     (gl:with-primitives :lines
	       (gl:vertex 0 0 0)
	       (gl:vertex 0 1 0))
	     (gl:with-primitives :lines
	       (gl:vertex 0 0 0)
	       (gl:vertex 0 0 1))
	     (gl:with-primitives :lines
	       (gl:vertex 1 0 0)
	       (gl:vertex 1 1 0))
	     (gl:with-primitives :lines
	       (gl:vertex 1 0 0)
	       (gl:vertex 1 0 1))
	     (gl:with-primitives :lines
	       (gl:vertex 0 1 0)
	       (gl:vertex 1 1 0))
	     (gl:with-primitives :lines
	       (gl:vertex 0 1 0)
	       (gl:vertex 0 1 1))
	     (gl:with-primitives :lines
	       (gl:vertex 0 0 1)
	       (gl:vertex 1 0 1))
	     (gl:with-primitives :lines
	       (gl:vertex 0 0 1)
	       (gl:vertex 0 1 1))
	     (gl:with-primitives :lines
	       (gl:vertex 1 1 0)
	       (gl:vertex 1 1 1))
	     (gl:with-primitives :lines
	       (gl:vertex 1 0 1)
	       (gl:vertex 1 1 1))
	     (gl:with-primitives :lines
	       (gl:vertex 0 1 1)
	       (gl:vertex 1 1 1))
	     (sdl:update-display)))))

(main)
