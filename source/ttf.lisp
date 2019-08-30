(ql:quickload :lispbuilder-sdl)
(ql:quickload :lispbuilder-sdl-ttf)

(defparameter *ttf-font-YUYUKO*
  (make-instance 'sdl:ttf-font-definition
		 :size 32
		 :filename "YUYUKOhira-kana-Script.otf")) ; ttfファイルの場所を指定する
(defparameter *ttf-font-nene*
  (make-instance 'sdl:ttf-font-definition
		 :size 32
		 :filename "nene.ttf")) ; ttfファイルの場所を指定する

(defun font-example ()
  (sdl:with-init ()
    (sdl:window 600 96 :title-caption "SDL-TTF Font Example" :icon-caption "SDL-TTF Font Example")
    (setf (sdl:frame-rate) 30)
    (sdl:fill-surface sdl:*white* :surface sdl:*default-display*)
    (unless (sdl:initialise-default-font *ttf-font-nene*)
      (error "FONT-EXAMPLE: Cannot initialize the default font."))
    (sdl:draw-string-solid-* "Text UTF8 - Solid 日本語テスト" 0 0
			     :color sdl:*black*)
    (sdl:draw-string-shaded-* "Text UTF8 - Shaded 日本語テスト" 0 32
			      sdl:*black*
			      sdl:*yellow*)
    (sdl:draw-string-blended-* "Text UTF8 - Blended 日本語テスト" 0 64
			       :color sdl:*black*)
    (sdl:update-display)
    (sdl:with-events ()
      (:quit-event () t)
      (:video-expose-event () (sdl:update-display))
      (:key-down-event ()
		       (when (sdl:key-down-p :sdl-key-escape)
			 (sdl:push-quit-event))))))

(font-example)
