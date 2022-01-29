;;; emacs-func.el --- Some useful functions and commands -*- lexical-binding: t -*-

(use-package dash
  :ensure t)

(defun first-avail-font (&rest fonts)
  "Accept multiple font family names and return the first available one."
  (let ((system-font-list (font-family-list)))
    (--first (member it system-font-list) fonts)))
