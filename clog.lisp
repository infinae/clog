;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CLOG - The Common Lisp Omnificent GUI                                 ;;;;
;;;; (c) 2020-2021 David Botton                                            ;;;;
;;;; License BSD 3 Clause                                                  ;;;;
;;;;                                                                       ;;;;
;;;; clog.lisp                                                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exports - clog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(mgl-pax:define-package :clog
  (:documentation "The Common List Omnificent GUI - Parent package")  
  (:local-nicknames (:cc :clog-connection))
  (:use #:cl #:mgl-pax))

(in-package :clog)

(defsection @clog-manual (:title "The CLOG manual")
  "The Common Lisp Omnificient GUI, CLOG for short, uses web technology
to produce graphical user interfaces for applications locally or
remotely. The CLOG package starts up the connectivity to the browser
or other websocket client (often a browser embedded in a native
application."

  (clog asdf:system)

  (@clog-top-level section))

(defsection @clog-top-level (:title "CLOG Top level")

  "CLOG Startup and Shutdown"
  (initialize function)
  (shutdown   function)

  "CLOG Obj"
  (clog-obj class)

  "CLOG Obj - Low Level Creation Methods"
  (create-child (method () (clog-obj t)))
  (attach-as-child (method () (clog-obj t)))

  "CLOG Obj - Placement Methods"
  (place-after            (method () (clog-obj t)))
  (place-before           (method () (clog-obj t)))
  (place-inside-top-of    (method () (clog-obj t)))
  (place-inside-bottom-of (method () (clog-obj t)))

  
  "CLOG Low Level binding functions"
  (attach           function)
  (create-with-html function)
    
  "CLOG utilities"
  (open-browser function))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - clog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-obj ()
  ((connection-id
    :reader connection-id
    :initarg :connection-id)
   (html-id
    :reader html-id
    :initarg :html-id))
  (:documentation "CLOG objects (clog-obj) encapsulate the connection between
lisp and the HTML DOM element."))

;;;;;;;;;;;;;;;
;; script-id ;;
;;;;;;;;;;;;;;;

(defmethod script-id ((obj clog-obj))
  "Return the script id for OBJ based on the html-id set during attachment. (Private)"
  (if (eql (html-id obj) 0)
      "'body'"
      (format nil "clog['~A']" (html-id obj))))

;;;;;;;;;;;;
;; jquery ;;
;;;;;;;;;;;;

(defmethod jquery ((obj clog-obj))
  "Return the jquery accessor for OBJ. (Private)"
  (format nil "$(~A)" (script-id obj)))

;;;;;;;;;;;;;;;;;;;;
;; jquery-execute ;;
;;;;;;;;;;;;;;;;;;;;

(defmethod jquery-execute ((obj clog-obj) method)
  "Execute the jquery METHOD on OBJ. (Private)"
  (cc:execute (connection-id obj)
	      (format nil "~A.~A" (jquery obj) method)))

;;;;;;;;;;;;;;;;;;
;; jquery-query ;;
;;;;;;;;;;;;;;;;;;

(defmethod jquery-query ((obj clog-obj) method)
  "Execute the jquery METHOD on OBJ and return result. (Private)"
  (cc:query (connection-id obj)
	    (format nil "~A.~A" (jquery obj) method)))

;;;;;;;;;;;;;;;;;;
;; create-child ;;
;;;;;;;;;;;;;;;;;;

(export 'create-child)
(defmethod create-child ((obj clog-obj) html &key (auto-place t))
  "Create a new clog-obj from HTML element as child of OBJ and if :AUTO-PLACE
place-inside-bottom-of OBJ."
  (let ((child (create-with-html (connection-id obj) html)))
    (if auto-place
	(place-inside-bottom-of obj child)
	child)))

;;;;;;;;;;;;;;;;;;;;;
;; attach-as-child ;;
;;;;;;;;;;;;;;;;;;;;;

(export 'attach-as-child)
(defmethod attach-as-child ((obj clog-obj) html-id)
  "Create a new clog-obj and attach an existing element with HTML-ID. The
HTML-ID must be unique."
  (cc:execute (connection-id obj) (format nil "clog['~A']=$('#~A')" html-id html-id))
  (make-instance 'clog-obj :connection-id (connection-id obj) :html-id html-id))

;;;;;;;;;;;;;;;;;
;; place-after ;;
;;;;;;;;;;;;;;;;;

(export 'place-after)
(defmethod place-after ((obj clog-obj) next-obj)
  "Places NEXT-OBJ after OBJ in DOM"
  (jquery-execute obj (format nil "after(~A)" (script-id next-obj)))
  next-obj)

;;;;;;;;;;;;;;;;;;
;; place-before ;;
;;;;;;;;;;;;;;;;;;

(export 'place-before)
(defmethod place-before ((obj clog-obj) next-obj)
  "Places NEXT-OBJ before OBJ in DOM"
  (jquery-execute obj (format nil "before(~A)" (script-id next-obj)))
  next-obj)

;;;;;;;;;;;;;;;;;;;;;;;;;
;; place-inside-top-of ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(export 'place-inside-top-of)
(defmethod place-inside-top-of ((obj clog-obj) next-obj)
  "Places NEXT-OBJ inside top of OBJ in DOM"
  (jquery-execute obj (format nil "prepend(~A)" (script-id next-obj)))
  next-obj)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ploace-inside-bottom-of ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(export 'place-inside-bottom-of)
(defmethod place-inside-bottom-of ((obj clog-obj) next-obj)
  "Places NEXT-OBJ inside bottom of OBJ in DOM"
  (jquery-execute obj (format nil "append(~A)" (script-id next-obj)))
  next-obj)


;;;;;;;;;;;;;;;;
;; initialize ;;
;;;;;;;;;;;;;;;;

(defvar *on-new-window* nil "Store the on-new-window handler")

(defun on-connect (id)
  (when cc:*verbose-output*
    (format t "Start new window handler on connection-id - ~A" id))
  (let ((body (make-instance 'clog-obj :connection-id id :html-id 0)))
    (funcall *on-new-window* body)))
    
(defun initialize (on-new-window
		   &key
		     (host           "0.0.0.0")
		     (port           8080)
		     (boot-file      "/boot.html")
		     (static-root    #P"./static-files/"))
  "Inititalze CLOG on a socket using HOST and PORT to serve BOOT-FILE as 
the default route to establish web-socket connections and static files
located at STATIC-ROOT."
  (setf *on-new-window* on-new-window)
  
  (cc:initialize #'on-connect
		 :host host
		 :port port
		 :boot-file boot-file
		 :static-root static-root))

;;;;;;;;;;;;;;
;; shutdown ;;
;;;;;;;;;;;;;;

(defun shutdown ()
  "Shutdown CLOG."
  (cc:shutdown-clog))

;;;;;;;;;;;;
;; attach ;;
;;;;;;;;;;;;

(defun attach (connection-id html-id)
  "Create a new clog-obj and attach an existing element with HTML-ID on
CONNECTION-ID to it and then return it. The HTML-ID must be unique."
  (cc:execute connection-id (format nil "clog['~A']=$('#~A')" html-id html-id))
  (make-instance 'clog-obj :connection-id connection-id :html-id html-id))

;;;;;;;;;;;;;;;;;;;;;;
;; create-with-html ;;
;;;;;;;;;;;;;;;;;;;;;;

(defun create-with-html (connection-id html)
  "Create a new clog-obj and attach it to HTML on CONNECTION-ID. There must be
a single outer block that will be set to an internal id. The returned clog-obj
requires placement or will not be visible, ie. place-after, etc"
  (let ((web-id (cc:generate-id)))
    (cc:execute
     connection-id
     (format nil "clog['~A']=$(\"~A\"); clog['~A'].first().prop('id','~A')"
	     web-id html web-id web-id))
    (make-instance 'clog-obj :connection-id connection-id :html-id web-id)))

;;;;;;;;;;;;;;;;;;
;; open-browser ;;
;;;;;;;;;;;;;;;;;;

(defun open-browser (&key (url "http://127.0.0.1:8080"))
  "Open a web browser to URL."
  (trivial-open-browser:open-browser url))
