(ql:quickload :alexandria)
(defparameter *alist* '((hoge (1 2 3))
			(fuga (4 5 6))))

(defparameter *hash*(alexandria:plist-hash-table '("a" (0 1 2)
						   "b" (3 4 5)
						   "A" (0 2 4)
						   "B" (6 8 10))
						 :test #'equal))
(defconstant +default-text-strings+ "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゐゆゑよらりるれろわをん　っ、。がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽabcdefghijklmnopqrstuvwxyz!?,.ABCDEFGHIJKLMNOPQRSTUVWXYZ”-=$")
(defun make-text-hash-table (string list)
  (unless *hash*
    (setf *hash* (alexandria:plist-hash-table '() :test #'equal)))
  (let ((ch (loop for char across string collect
		 (format nil "~a" char))))
    (mapcar (lambda (lis char)
	      (setf (gethash char *hash*) lis))
	    list ch)))

(defun make-text-vlist (nxn)
  (let ((vlist nil))
    (dotimes (row  22)
      (dotimes (col (if (< row 16)
			5
			10))
	(if (eql row 9)
	    (if (or (eql col 1)
		    (eql col 2)
		    (eql col 3))
		nil
		(push (list row col nxn)  vlist))
	    (push (list row col nxn)  vlist))))
    (reverse vlist)))

(defun init-text-table (&optional (string +default-text-strings+) vlist)
  )

(defclass text-map ()
  ((file :initarg nil
	 :initform file)
   (table :initarg nil
	  :initform table)))
