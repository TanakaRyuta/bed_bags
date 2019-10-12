(defclass mouse ()
  ;;define use key
  ((mouse-x :initform nil)
   (mouse-y :initform nil)
   (mouse-x-rel :initform nil)
   (mouse-y-rel :initform nil)
   (mouse-x-state :initform nil)
   (mouse-y-state :initform nil)))

(defmethod set-mouse ((mouse mouse) _x _y _x-rel _y-rel)
  (with-slots (mouse-x mouse-y mouse-x-rel mouse-y-rel) mouse
    (setf mouse-x _x)
    (setf mouse-y _y)
    (setf mouse-x-rel _x-rel)
    (setf mouse-y-rel _y-rel)))

(defmethod get-mouse ((mouse mouse))
  (with-slots (mouse-x-rel mouse-y-rel) mouse
    '(mouse-x-rel mouse-y-rel)))
(defmethod rotate-angle((mouse mouse))
  (:gl-rotate (* 0.1 (nth 0 (get-mouse mouse))) 0 1 0))

      
