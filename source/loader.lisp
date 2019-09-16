(defun load-png-image (png-file)
  (sdl:convert-to-display-format :surface (sdl:load-image png-file)
                                 :enable-alpha t
                                 :pixel-alpha t))

(defun load-a-texture (filename)
  (let ((texture (car (gl:gen-textures 1)))
        (image (sdl-image:load-image filename)))
    (gl:bind-texture :texture-2d texture)
    (gl:tex-parameter :texture-2d :texture-min-filter :linear)

    (sdl-base::with-pixel (pix (sdl:fp image))
      ;; we should probably be a bit more intelligent about this, but this
      ;; handles some common cases
      (let ((texture-format (ecase (sdl-base::pixel-bpp pix)
                              (3 :rgb)
                              (4 :rgba))))
        ;; we should also handle this properly, by adjusting the
        ;; settings of gl:pixel-store
        (assert (and (= (sdl-base::pixel-pitch pix)
                        (* (sdl:width image) (sdl-base::pixel-bpp pix)))
                     (zerop (rem (sdl-base::pixel-pitch pix) 4))))
        (gl:tex-image-2d :texture-2d 0 :rgba
                         (sdl:width image) (sdl:height image)
                         0
                         texture-format
                         :unsigned-byte (sdl-base::pixel-data pix))))
    texture))
