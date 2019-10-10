(ql:quickload '(:png-read
		:cl-ppcre))
(defun load-texture (png-file width height chunk)
  (let ((png-image (png-read:read-png-file png-file))
	(array (make-array (* width height chunk)))
	)
    (setf png-image (png-read:image-data png-image))
    (dotimes (i width)
      (dotimes (j height)
	(dotimes (k chunk)
	  (setf (aref array (+ k 
			       (* chunk j)
			       (* chunk height i)))
		(aref  png-image i j k)))))
    ;;(format t "~a~%" array)
    array))

(defun read-obj(file-path)
  (with-open-file (obj file-path :direction :input)
    (let ((lis ()))
      (loop for line = (read-line obj nil)
	 while line do
	   (cond ((eql 1 (mismatch "v" line))
		  (setf lis
			(append lis
				(mapcar
				 (lambda (x)
				   (let ((numlis ()))
				     (append numlis (read-from-string x))))
				 (cdr (ppcre:split " " line))))))))
      lis)))

  (defun read-mtl()
    )
