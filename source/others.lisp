(defun file-path (loot file-name)
  ;;
  (merge-pathnames
   (file-namestring file-name)
   (merge-pathnames loot)))

(defun all-append (list1 list2)
  (if (and t list2)
      (all-append (append list1 (car list2))
		  (cdr list2))))

(defparameter list1 #((1 2 3) (4 5 6)))
