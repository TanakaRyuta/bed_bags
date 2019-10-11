;;load file
(load "loader.lisp" :external-format :utf-8)

;;
(defclass player ()
  (;位置position
   (plposx :initform 0)
   (plposy :initform 0)
   (plposz :initform 0)
   ;向きorientation
   ;(anglex )
   ;(angley )
   ;(anglez )
   ))
(defmethod get_player_pos((player player))
  (with-slots (plposx plposy plposz) player
   '(plposx plposy plposz)
  ))
(defmethod set_player_pos((player player) _posx _posy _posz)
  (with-slots (plposx plposy plposz) player
    (setf plposx _posx)
    (setf plposy _posy)
    (setf plposz _posz)
  ))
 
