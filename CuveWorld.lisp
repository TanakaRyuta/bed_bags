(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)

(defconstant +window-width+ 640)
(defconstant +window-height+ 480)

(defun main ()
  (sdl:with-init ()
    (sdl:window +window-width+ +window-height+
		:title-caption "タイトル"
		:icon-caption "title"
		;;:fullscreen
		;;:no-frame
		:opengl t
		:opengl-attributes '((:sdl-gl-doublebuffer 1)))
    (gl:clear-color 0 0 0 0)
    (gl:matrix-mode :projection)
    (gl:load-identity)
    (gl:ortho 0 1 0 1 -1 1)
    (sdl:with-events ()
      (:quit-event () t)
      (:key-down-event (:key key)
		       (when (sdl:key= key :sdl-key-escape)
			 (sdl:push-quit-event)))
      (:idle ()
	     (gl:clear :color-buffer-bit)
	     (gl:color 0 0 1)
	     (gl:with-primitive :polygon
	       (gl:vertex 0 0 0)
	       (gl:vertex 0.25 0 0)
	       (gl:vertex 0.25 0.25 0)
	       (gl:vertex 0 0.25 0))
	     (gl:flush)
	     (sdl:update-display)))))
