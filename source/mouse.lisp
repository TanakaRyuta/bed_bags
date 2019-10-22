(load "others.lisp" :external-format :utf-8)

(defclass mouse ()
  ;;define use key
  ((mouse-x :initform 0)
   (mouse-y :initform 0)
   (mouse-x-rel :initform 0)
   (mouse-y-rel :initform 0)))

(defmethod set-mouse ((mouse mouse) _x-rel _y-rel)
  (with-slots (mouse-x-rel mouse-y-rel) mouse
    (setf mouse-x-rel (+ mouse-x-rel _x-rel))
    (setf mouse-y-rel (+ mouse-x-rel _y-rel))))

(defmethod get-mouse ((mouse mouse))
  (with-slots (mouse-x-rel mouse-y-rel) mouse
    (list mouse-x-rel mouse-y-rel)))

(defun move-deg (move)
  (Deg (* 180 pi (/ move 3000))))

(defmethod rotate-angle(sensitive (mouse mouse) &key (inverse nil))
  (let ((theta (* (move-deg (nth 0 (get-mouse mouse))) sensitive)))
    (if inverse
	(* -1 theta)
	theta)))


