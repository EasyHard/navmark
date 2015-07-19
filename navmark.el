(defvar navmark/mark-ring nil "The list of saved marks (including global and buffer-local).")
(defcustom navmark/mark-ring-max 256 "Tha max number of saved marks.")

;; data structure
(defun navmark/marker-buffer (marker)
  "Return nil if buffer is deleted."
  (let ((buffer (car marker)))
    (if (buffer-live-p buffer)
        buffer
      nil)))

(defun navmark/marker-position (marker) (cdr marker))
(defun navmark/marker-make (buffer position) (cons buffer position))

;; functions
(defun navmark/forward ()
  "moving forward in the mark ring. Does nothing if mark ring is empty."
  (interactive)
  (while (and navmark/mark-ring (not (navmark/marker-buffer (car (last navmark/mark-ring)))))
    (nbutlast navmark/mark-ring))
  (or navmark/mark-ring
      (error "navmark mark ring is empty."))
  (let* ((marker (car (last navmark/mark-ring)))
         (buffer (navmark/marker-buffer marker))
         (position (navmark/marker-position marker)))
    (setq navmark/mark-ring (nconc (last navmark/mark-ring) (butlast navmark/mark-ring)))
    (set-buffer buffer)
    (or (and (>= position (point-min))
             (<= position (point-max)))
        (if widen-automatically
            (widen)
          (error "navmark mark position is outside accessible part of buffer")))
    (goto-char position)
    (switch-to-buffer buffer)))

(defun navmark/backward ()
  "moving backward in the mark ring. Does nothing if mark ring is empty."
  (interactive)
  (while (and navmark/mark-ring (not (navmark/marker-buffer (car navmark/mark-ring))))
    (seq navmark/mark-ring (cdr navmark/mark-ring)))
  (or navmark/mark-ring
      (error "navmark mark ring is empty."))
  (let* ((marker (car navmark/mark-ring))
         (buffer (navmark/marker-buffer marker))
         (position (navmark/marker-position marker)))
    (setq navmark/mark-ring (nconc (cdr navmark/mark-ring)
                                   (list (car navmark/mark-ring))))
    (set-buffer buffer)
    (or (and (>= position (point-min))
             (<= position (point-max)))
        (if widen-automatically
            (widen)
          (error "navmark mark position is outside accessible part of buffer")))
    (goto-char position)
    (switch-to-buffer buffer)))

(defun navmark/ensure-position-moved-or-nowhere (func &rest r)
  "A wrapper of shift and unshift, ensuring shifting/unshifting to a new position."
  (let* ((origin-position (point))
         (origin-buffer (current-buffer)))
    (apply func r)
    (while (and (eq (point) origin-position) (eq origin-buffer (current-buffer)) (not (eq 1 (length navmark/mark-ring))))
      (apply func r)
      )))

(add-function :around (symbol-function 'navmark/forward) 'navmark/ensure-position-moved-or-nowhere)
(add-function :around (symbol-function 'navmark/backward) 'navmark/ensure-position-moved-or-nowhere)

(defun navmark/add-mark (&optional location append &rest r)
  "add a mark into navmark/mark-ring when push-mark is called."
  (let* ((marker (navmark/marker-make (current-buffer) (or location (point)))))
    (when (> (length navmark/mark-ring) navmark/mark-ring-max)
      (nbutlast navmark/mark-ring))
    (add-to-list 'navmark/mark-ring marker append)))


(add-function :after (symbol-function 'push-mark) 'navmark/add-mark)
(global-set-key (kbd "M-p") 'navmark/backward)
(global-set-key (kbd "M-n") 'navmark/forward)

(provide 'navmark)
