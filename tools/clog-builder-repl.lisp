(in-package "CLOG-TOOLS")
(defclass clog-builder-repl (clog:clog-panel)
  (    (clog-terminal-1 :reader clog-terminal-1)
))
(defun create-clog-builder-repl (clog-obj &key (hidden nil) (class nil) (html-id nil) (auto-place t))
  (let ((panel (change-class (clog:create-div clog-obj :content "<div style=\"--pixel-density:1; --char-width:7.20312; box-sizing: content-box; position: absolute; inset: 0px;\" class=\"terminal\" id=\"CLOGB3867322458\" data-clog-name=\"clog-terminal-1\"></div>"
         :hidden hidden :class class :html-id html-id :auto-place auto-place) 'clog-builder-repl)))
    (setf (slot-value panel 'clog-terminal-1) (attach-as-child clog-obj "CLOGB3867322458" :clog-type 'CLOG-TERMINAL:CLOG-TERMINAL-ELEMENT :new-id t))
    (let ((target (clog-terminal-1 panel))) (declare (ignorable target)) (clog-terminal:attach-clog-terminal target :greetings "CLOG Builder REPL") (clog-terminal:prompt target "> "))
    (clog-terminal:set-on-command (clog-terminal-1 panel) (lambda (target data) (declare (ignorable target data)) (clog-terminal:echo target (capture-eval data :clog-obj clog-obj))))
    panel))