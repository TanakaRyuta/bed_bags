(defun load-png-image (png-file)
  (let ((png (png-read:read-png-file png-file)))
    png))

(defun load-png-texture (png-file)
  (let ((png-image (load-png-image png-file)))
    (png-read:image-data png-image)))

(defun test-load-png-image (png-file)
  (sdl:convert-to-display-format :surface (sdl:load-image png-file)
                                 :enable-alpha t
                                 :pixel-alpha t))


