;;
(defclass status
    ((hp :initarg :hp
	 :initform 1
	 :accessor hp)
     (mp :initarg :mp
	 :initform 1
	 :accessor mp)
     (str :initarg :str
	  :initform 1
	  :accessor str)
     (con :initarg :con
	  :initform 1
	  :accessor con)
     (pow :initarg :pow
	  :initform 1
	  :accessor pow)
     (dex :initarg :dex
	  :initform 1
	  :accessor dex)
     (app :initarg :app
	  :initform 1
	  :accessor app)
     (siz :initarg :siz
	  :initform 1
	  :accessor siz)
     (int :initarg :int
	  :initform 1
	  :accessor int)
     (edu :initarg :edu
	  :initform 1
	  :accessor edu)
     (san :initarg :san
	  :initform 1
	  :accessor san)
     (luk :initarg :luk
	  :initform 1
	  :accessor luk)
     (idea :initarg :idea
	   :initform 1
	   :accessor idea)
     (kl :initarg :kl
	 :initform 1
	 :accessor kl)
     (skill :initarg :skill
	    :initform 1
	    :accessor skill)))

(defmethod set-status (obj status)
  ())

(defun dice-roll (faces)
  (+ (random faces) 1))

(defun dice-ndn (num faces)
  (loop repeat num
     sum (dice-roll faces)))
