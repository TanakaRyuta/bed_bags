(defgeneric set-key-state (key key-press key-state))

(defclass key-state ()
  ;;define use key
  ((right
    :initform nil)
   (left
    :initform nil)
   (up
    :initform nil)
   (down
    :initform nil)))

(defmethod set-key-state (key key-press (key-state key-state))
  (with-slots (right left up down) key-state
    (cond ((sdl:key= key :sdl-key-right)
	   (setf right key-press))
	  ((sdl:key= key :sdl-key-left)
	   (setf left key-press))
	  ((sdl:key= key :sdl-key-up)
	   (setf up key-press))
	  ((sdl:key= key :sdl-key-down)
	   (setf down key-press)))))

(defun test-input-key (current-key)
  (with-slots (right left) current-key
    (cond ((and right t)
	   (format t "-> "))
	  ((and left t)
	   (format t "<- ")))
    (fresh-line)))
