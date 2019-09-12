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
    :initform nil)
   (sright
    :initform nil)
   (sleft
    :initform nil)
   (sup
    :initform nil)
   (sdown
    :initform nil)))

(defmethod set-key-state (key key-press (key-state key-state))
  (with-slots (right left up down sright sleft sup sdown) key-state
    (cond ((sdl:key= key :sdl-key-right) (setf right key-press))
	  ((sdl:key= key :sdl-key-left)  (setf left key-press))
	  ((sdl:key= key :sdl-key-up)    (setf up key-press))
	  ((sdl:key= key :sdl-key-down)  (setf down key-press))
	  ((sdl:key= key :sdl-key-A)     (setf sleft key-press))
	  ((sdl:key= key :sdl-key-D)     (setf sright key-press))
	  ((sdl:key= key :sdl-key-W)     (setf sup key-press))
	  ((sdl:key= key :sdl-key-S)     (setf sdown key-press))
	  (#|(sdl:key= key :sdl-key-)    (setf key key-press))|#))

(defun test-input-key (current-key)
  (with-slots (right left up down sright sleft sup sdown) current-key
    (and right (format t "→ "))
    (and left (format t "← "))
    (and up (format t "↑ "))
    (and down (format t "↓ "))
    (and sright (format t "D "))
    (and sleft (format t "A "))
    (and sup (format t "W "))
    (and sdown (format t "S "))
    (fresh-line)))
