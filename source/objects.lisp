(ql:quickload :cl-opengl)
(ql:quickload :cl-glu)

(defvar *cuve-line-vertex*
  (list
   (list 0 1)
   (list 0 3)
   (list 0 4)
   (list 1 2)
   (list 1 5)
   (list 2 3)
   (list 2 6)
   (list 3 7)
   (list 4 5)
   (list 4 7)
   (list 5 6)
   (list 6 7)))
(defvar *object-num* 0)
(defvar *cube-face-vertex*
  (list
   (list 3 2 1 0)
   (list 4 5 6 7)
   (list 0 1 5 4)
   (list 1 2 6 5)
   (list 2 3 7 6)
   (list 3 0 7 4)))

(defvar *cube-vertex*
  (list
   (list 0.0 0.0 0.0)
   (list 1.0 0.0 0.0)
   (list 1.0 1.0 0.0)
   (list 0.0 1.0 0.0)
   (list 0.0 0.0 1.0)
   (list 1.0 0.0 1.0)
   (list 1.0 1.0 1.0)
   (list 0.0 1.0 1.0)))

(defun face-cube (x y z r)
  (+ *object-num* 1)
  (gl:push-matrix)
  (gl:translate x y z)
  (gl:scale r r r)
  (gl:with-primitives :quads
    (gl:vertex 0 1 0) (gl:vertex 1 1 0)
    (gl:vertex 1 0 0) (gl:vertex 0 0 0))
  (gl:with-primitives :quads
    (gl:vertex 0 0 0) (gl:vertex 1 0 0)
    (gl:vertex 1 0 1) (gl:vertex 0 0 1))
  (gl:with-primitives :quads
    (gl:vertex 0 0 0) (gl:vertex 0 0 1)
    (gl:vertex 0 1 1) (gl:vertex 0 1 0))
  (gl:with-primitives :quads
    (gl:vertex 0 0 1) (gl:vertex 1 0 1)
    (gl:vertex 1 1 1) (gl:vertex 0 1 1))
  (gl:with-primitives :quads
    (gl:vertex 0 1 0) (gl:vertex 0 1 1)
    (gl:vertex 1 1 1) (gl:vertex 1 1 0))
  (gl:with-primitives :quads
    (gl:vertex 1 0 0) (gl:vertex 1 1 0)
    (gl:vertex 1 1 1) (gl:vertex 1 0 1))
  (gl:pop-matrix))

;;
(defun frame-cube (x y z r)  
  (+ *object-num* 1)
  (gl:push-matrix)
  (gl:translate x y z)
  (gl:scale r r r)
  (gl:with-primitives :lines
    (gl:vertex -0.5 -0.5 -0.5)
    (gl:vertex 0.5 -0.5 -0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 -0.5  -0.5)
    (gl:vertex -0.5 0.5 -0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 -0.5 -0.5)
    (gl:vertex -0.5 -0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex 0.5 -0.5 -0.5)
    (gl:vertex 0.5 0.5 -0.5))
  (gl:with-primitives :lines
    (gl:vertex 0.5 -0.5 -0.5)
    (gl:vertex 0.5 -0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 0.5 -0.5)
    (gl:vertex 0.5 0.5 -0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 0.5 -0.5)
    (gl:vertex -0.5 0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 -0.5 0.5)
    (gl:vertex 0.5 -0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 -0.5 0.5)
    (gl:vertex -0.5 0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex 0.5 0.5 -0.5)
    (gl:vertex 0.5 0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex 0.5 -0.5 0.5)
    (gl:vertex 0.5 0.5 0.5))
  (gl:with-primitives :lines
    (gl:vertex -0.5 0.5 0.5)
    (gl:vertex 0.5 0.5 0.5))
  (gl:pop-matrix))

(defun face-frame-cube (x y z r cr cg cb)
  (+ *object-num* 1)
  (gl:push-matrix)
  ;;(gl:load-identity)
  (gl:translate x y z)
  (gl:scale r r r)

  (gl:color cr cg cb)
  (gl:with-primitives :quads
    (gl:vertex 0 1 0) (gl:vertex 1 1 0)
    (gl:vertex 1 0 0) (gl:vertex 0 0 0))
  (gl:with-primitives :quads
    (gl:vertex 0 0 0) (gl:vertex 1 0 0)
    (gl:vertex 1 0 1) (gl:vertex 0 0 1))
  (gl:with-primitives :quads
    (gl:vertex 0 0 0) (gl:vertex 0 0 1)
    (gl:vertex 0 1 1) (gl:vertex 0 1 0))
  (gl:with-primitives :quads
    (gl:vertex 0 1 0) (gl:vertex 0 1 1)
    (gl:vertex 1 1 1) (gl:vertex 1 1 0))
  (gl:with-primitives :quads
    (gl:vertex 0 0 1) (gl:vertex 1 0 1)
    (gl:vertex 1 1 1) (gl:vertex 0 1 1))
  (gl:with-primitives :quads
    (gl:vertex 1 0 0) (gl:vertex 1 1 0)
    (gl:vertex 1 1 1) (gl:vertex 1 0 1))
  
  (gl:color 0 0 0)
  (gl:with-primitives :lines
    (gl:vertex 0 0 0)
    (gl:vertex 1 0 0))
  (gl:with-primitives :lines
    (gl:vertex 0 0 0)
    (gl:vertex 0 1 0))
  (gl:with-primitives :lines
    (gl:vertex 1 0 0)
    (gl:vertex 1 1 0))
  (gl:with-primitives :lines
    (gl:vertex 0 1 0)
    (gl:vertex 1 1 0))
  (gl:with-primitives :lines
    (gl:vertex 0 0 0)
    (gl:vertex 0 0 1))
  (gl:with-primitives :lines
    (gl:vertex 1 0 0)
    (gl:vertex 1 0 1))
  (gl:with-primitives :lines
    (gl:vertex 0 0 1)
    (gl:vertex 1 0 1))
  (gl:with-primitives :lines
    (gl:vertex 0 1 0)
    (gl:vertex 0 1 1))
  (gl:with-primitives :lines
    (gl:vertex 0 0 1)
    (gl:vertex 0 1 1))
  (gl:with-primitives :lines
    (gl:vertex 1 0 1)
    (gl:vertex 1 1 1))
  (gl:with-primitives :lines
    (gl:vertex 0 1 1)
    (gl:vertex 1 1 1))
  (gl:with-primitives :lines
    (gl:vertex 1 1 0)
    (gl:vertex 1 1 1))
  (gl:pop-matrix))

(defun axis (r)
  ;;axis
  (gl:push-matrix)
  (gl:color 1 0 0)
  (gl:with-primitives :lines
    (gl:vertex (- 0 r) 0 0)
    (gl:vertex r 0 0))
  (gl:color 0 1 0)
  (gl:with-primitives :lines
    (gl:vertex 0 (- 0 r) 0)
    (gl:vertex 0 r 0))
  (gl:color 0 0 1)
  (gl:with-primitives :lines
    (gl:vertex 0 0 (- 0 r))
    (gl:vertex 0 0 r))
  (gl:pop-matrix))
