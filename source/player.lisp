;;load file
(load "loader.lisp" :external-format :utf-8)
(load "key.lisp" :external-format :utf-8)

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

(defmethod set-player-pos ((player player) x y z)
  (with-slots (plposx plposy plposz) player
    (setf plposx x)
    (setf plposy y)
    (setf plposz z)))

(defmethod get_player_angle ((player player))
  (with-slots (pltheta) player
    pltheta))

(defmethod set-player-angle ((player player) theta)
  (with-slots (pltheta) player
    (setf pltheta theta))
  (* -1 theta))

(defmethod move-player ((player player) (key-state key-state))
  (with-slots (plposx plposy plposz pltheta) player
    (with-slots (right left up down) key-state
      (and up
	   (set-player-pos player
			   (- plposx (cos (rad pltheta)))
			   0
			   (+ plposz (sin (rad pltheta)))))
      (and down
	   (set-player-pos player
			   (- plposx (cos (rad (+ 180 pltheta))))
			   0
			   (+ plposz (sin (rad (+ 180 pltheta))))))
      (and right
	   (set-player-pos player
			   (- plposx (cos (rad (+ 270 pltheta))))
			   0
			   (+ plposz (sin (rad (+ 270 pltheta))))))
      (and left
	   (set-player-pos player
			   (- plposx (cos (rad (+ 90 pltheta))))
			   0
			   (+ plposz (sin (rad (+ 90 pltheta)))))))))
