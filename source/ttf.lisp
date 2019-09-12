(ql:quickload '(:lispbuilder-sdl
		:lispbuilder-sdl-ttf
		:glisph))

(load "others.lisp" :external-format :utf-8)

(defvar *debug* nil)

(defvar *font* nil)
(defvar *table* nil)
(defvar *text* #("12345"))

(defun init-gli (width height)
  (gli:init width height)

  ;;set font
  (setf *font*
	(gli:open-font-loader (file-path "../ttf/" "PixelMplus10-Bold.ttf")))
  ;;make font-table
  (setf *table* (gli:make-glyph-table *font*))
  (loop for text across *text* do (gli:regist-glyphs *table* text))
  (setf *text*
	(gli:draw *table*
		  `(:size 24 :x 0 :y 0
			  :text (aref *text* 0)))))


(defmethod draw-text ()
  (gl:push-matrix)
  (gli:render *text*)
  (gl:pop-matrix))

(defmethod close-gli ()
  (gli:delete-glyph-table *table*)
  (gli:finalize))








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
