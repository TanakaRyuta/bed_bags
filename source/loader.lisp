(ql:quickload :png-read)
(defun load-texture (png-file width height chunk)
  (let ((png-image (png-read:read-png-file png-file))
	(array (make-array (* width height chunk)))
	)
    (setf png-image (png-read:image-data png-image))
    (format t "~a~%" png-image)
    (dotimes (i width)
      (dotimes (j height)
	(dotimes (k chunk)
	  (setf (aref array (+ k 
			       (* chunk j)
			       (* chunk height i)))
		(aref  png-image i j k)))))
    (format t "~a~%" array)
    array))
