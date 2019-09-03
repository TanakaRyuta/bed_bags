(ql:quickload :lispbuilder-sdl)
(ql:quickload :lispbuilder-sdl-ttf)

(load "others.lisp" :external-format :utf-8)

;;define fonts
(defparameter *ttf-font-YUYUKO*
  (make-instance 'sdl:ttf-font-definition
		 :size 32
		 ;;ttfファイルの場所を指定する
		 :filename "YUYUKOhira-kana-Script.otf"))
(defparameter *ttf-font-msgothic*
  (make-instance 'sdl:ttf-font-definition
		 :size 32
		 :filename (FILE-PATH "../ttf/" "msgothic.ttc")))

(defun init-font(font)
  (unless (sdl:initialise-default-font font)
    (error "set default font.")))

(defun font-example ()
  (sdl:with-init ()
    (sdl:window 600 96 :title-caption "SDL-TTF Font Example" :icon-caption "SDL-TTF Font Example")
    (setf (sdl:frame-rate) 30)
    (sdl:fill-surface sdl:*white* :surface sdl:*default-display*)
    (unless (sdl:initialise-default-font *ttf-font-msgothic*)
      (error "FONT-EXAMPLE: Cannot initialize the default font."))
    (sdl:draw-string-solid-* "Text UTF8 - Solid 日本語テスト" 0 0
			     :color sdl:*black*)
    (sdl:draw-string-shaded-* "Text UTF8 - Shaded 日本語テスト" 0 32
			      sdl:*black*
			      sdl:*yellow*)
    ;;(sdl:draw-string-blended-* "Text UTF8 - Blended 日本語テスト" 0 64
    ;;    :color sdl:*black*)
    (sdl:update-display)
    (sdl:with-events ()
      (:quit-event () t)
      (:video-expose-event () (sdl:update-display))
      (:key-down-event ()
		       (when (sdl:key-down-p :sdl-key-escape)
			 (sdl:push-quit-event))))))

(font-example)
