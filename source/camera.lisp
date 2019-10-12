(defgeneric set-pos (obj x y z))
(defgeneric set-angle (obj x y z))
(defgeneric move-angle (obj1 obj2))

(defvar *debug* nil)

;;camera object
(defclass camera ()
  ((posx
    :initarg :posx
    :initform 0)
   (posy
    :initarg :posy
    :initform 0)
   (posz
    :initarg :posz
    :initform 0)
   (anglex
    :initarg :anglex
    :initform 0)
   (angley
    :initarg :angley
    :initform 0)
   (anglez
    :initarg :anglez
    :initform 0)))

(defmethod set-pos ((camera camera) x y z)
  (with-slots (posx posy posz) camera
    (setf posx x)
    (setf posy y)
    (setf posz z)
    (and (eql *debug* t)
	 (progn
	   (format t "pos : ")
	   (format t "~a " posx)
	   (format t "~a " posy)
	   (format t "~a~%" posz)))))

(defmethod set-angle ((camera camera) x y z)
  (with-slots (anglex angley anglez) camera
    (setf anglex x)
    (setf angley y)
    (setf anglez z)
    (and (eql *debug* t)
	 (progn
	   (format t "angle : ")
	   (format t "~a " anglex)
	   (format t "~a " angley)
	   (format t "~a~%" anglez)))))

(defmethod move-angle ((key-obj key-state) (cam-obj camera))
  (with-slots (right left up down sright sleft sup sdown) key-obj
    (with-slots (posx posy posz anglex angley anglez) cam-obj
      (flet ((f-angle (px py pz ax ay az)
	       ;;set pos
	       (setf posx (+ posx px))
	       (setf posy (+ posy py))
	       (setf posz (+ posz pz))
	       
	       ;;set angle
	       (setf anglex (mod (+ anglex ax) 360))
	       (if (and (>= anglex 90)
			(< anglex 180))
		   (setf anglex 90))
	       (if (and (>= anglex 180)
			(< anglex 270))
		   (setf anglex 270))

	       (setf angley (mod (+ angley ay) 360))
	       
	       (setf anglez (mod (+ anglez az) 360))
	       (if (and (>= anglez 90)
			(< anglez 180))
		   (setf anglez 90))
	       (if (and (>= anglez 180)
			(< anglez 270))
		   (setf anglez 270))

	       ;;translate & rotate camera
	       (gl:rotate angley 0.0 1.0 0.0)
	       (gl:rotate anglex 1.0 0.0 0.0)
	       (gl:rotate anglez 0.0 0.0 1.0)
	       (gl:translate posx posy posz)
	       
	       (and (eql *debug* t)
		    (progn
		      (format t "move-pos : ")
		      (format t "~a " posx)
		      (format t "~a " posy)
		      (format t "~a~%" posz)
		      (format t "move-angle : ")
		      (format t "~a " anglex)
		      (format t "~a " angley)
		      (format t "~a~%" anglez)))))
	(and left   (f-angle 0.1 0 0 0 0 0))
	(and right  (f-angle -0.1 0 0 0 0 0))
	(and down   (f-angle 0.1 0.1 0 0 0 0))
	(and up     (f-angle -0.1 -0.1 0 0 0 0))
	(and sright (f-angle 0 0 0 0 0.1 0))
	(and sleft  (f-angle 0 0 0 0 -0.1 0))
	(and sup    (f-angle 0 0 0 0.1 0 -0.1))
	(and sdown  (f-angle 0 0 0 -0.1 0 0.1))))))
