(defun file-path (loot file-name)
  ;;
  (merge-pathnames
   (file-namestring file-name)
   (merge-pathnames loot)))

(defparameter list1 #((1 2 3) (4 5 6)))

(defun Rad (deg)
  (* (/ deg 180.0) pi))

(defun Deg (rad)
  (* (/ rad pi) 180.0))
