;;load file
(load "loader.lisp" :external-format :utf-8)

;;
(defclass player ()
  ;;位置position
  ((plposx :initform 0)
   (plposy :initform 0)
   (plposz :initform 0)
   ;;向きorientation
   (pltheta :initform 0)))

(defmethod get_player_pos ((player player))
  (with-slots (plposx plposy plposz) player
    (list plposx plposy plposz)))

(defmethod set_player_pos ((player player) x y z)
  (with-slots (plposx plposy plposz) player
    (setf plposx x)
    (setf plposy y)
    (setf plposz z)))

(defmethod get_player_angle ((player player))
  (with-slots (pltheta) player
    pltheta))

(defmethod set_player_angle ((player player) theta)
  (with-slots (pltheta) player
    (setf pltheta theta)))
