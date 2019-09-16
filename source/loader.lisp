(defun load-png-image (png-file)
  (sdl:convert-to-display-format :surface (sdl:load-image png-file)
                                 :enable-alpha t
                                 :pixel-alpha t))
