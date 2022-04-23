;;; init.el --- Emacs configuration entry point -*- lexical-binding: t -*-


;; Save custom settings in a seperate file
(setq custom-file (locate-user-emacs-file "etc/emacs-custom.el"))
(load custom-file t)

;; Set higher GC threshold for performance
(setq gc-cons-threshold (* 100 1024 1024))
;; Set higher IPC read threshold for applications like `lsp-mode'
(setq read-process-output-max (* 1 1024 1024))


;;; Package manager settings
(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(setq package-archive-priorities '(("gnu" . 10)
                                   ("nongnu" . 5)
                                   ("melpa" . 0)))
;; We have to set this manaully due to a gnupg bug on windows.
(setq package-gnupghome-dir (locate-user-emacs-file "elpa/gnupg"))
(package-initialize)

;; Ensure use-package is available.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package)
  (package-install 'delight))
(require 'use-package)
(setq use-package-always-ensure t)


;; no-littering keeps you .emacs.d clean
(use-package no-littering
  :init
  (setq no-littering-var-directory (expand-file-name (locate-user-emacs-file "cache/"))))


;;; Emacs basic settings
(add-to-list 'load-path (locate-user-emacs-file "site-lisp/"))
(load-file "~/.emacs.d/emacs-func.el")

(use-package emacs
  :custom
  ;; User name
  (user-full-name "stshine")
  ;; User email address
  (user-mail-address "pu.stshine@gmail.com")
  ;;; UI tweaks
  ;; Inhibit startup screen and message
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  ;; Hide toolbar and scrollbar
  (menu-bar-mode t)
  (tool-bar-mode nil)
  (scroll-bar-mode nil)
  ;; (display-battery-mode 1)
  ;; Disable cursor blinking
  (blink-cursor-mode nil)
  ;; Flash emacs instead of bell rings
  (visible-bell t)
  ;; Display line numbers
  (display-line-numbers t)
  ;; Show column number in modeline
  (column-number-mode t)
  ;; We use smartparens to show parenthesis
  (show-paren-mode nil)
  ;; Show image file as image in buffer
  (auto-image-file-mode 1)
  ;;; Editing settings
  ;; Set default major mode
  (major-mode 'text-mode)
  ;; Set displayed tab width
  (tab-width 4)
  ;; Smart tab behavior: complete
  (tab-always-indent 'complete)
  ;; Do not insert tabs when doing indentation
  (indent-tabs-mode nil)
  ;; Consider a period followed by a single space to be end of sentence.
  (sentence-end-double-space nil)
  ;; Show trailing whitespace of a line
  (show-trailing-whitespace t)
  ;; Visually indicate empty lines after the buffer end.
  (indicate-empty-lines t)
  ;;; Killing and yanking settings
  ;; Increase kill ring max length
  (kill-ring-max 300)
  ;; delete the selection with a keypress
  (delete-selection-mode t)
  ;; `kill-line' kills the whole line at the start of a line
  (kill-whole-line t)
  ;; Save unsaved clipboard into kill ring before killing operation
  (save-interprogram-paste-before-kill t)
  ;; Mouse yank at point instead of click
  (mouse-yank-at-point t)
  ;;; File backup settings
  ;; don't clobber symlinks
  (backup-by-copying t)
  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
  (delete-old-versions t)
  (kept-new-versions 3)
  (kept-old-versions 2)
  ;; use versioned backups
  (version-control t)
  :config
  (setq frame-title-format "%b - emacs")
  ;; Expect "y" or "n" when ask a yes-or-no question
  (fset 'yes-or-no-p 'y-or-n-p)
  ;;; Encoding settings
  (prefer-coding-system 'utf-8)
  (setq-default buffer-file-coding-system 'utf-8-unix)
  :bind
  (("<mouse-3>" .  'mouse-major-mode-menu))
  :delight eldoc-mode)


;;; Font and theme settings
(when (display-graphic-p)
  (defvar monospace-font (first-avail-font "Fira Code" "Consolas" "SF Mono" "DejaVu Sans Mono"))
  (defvar serif-font (first-avail-font "Source Serif Pro" "Georgia" "Libertine"))
  (defvar chinese-font (first-avail-font "Microsoft YaHei UI" "PingFang SC" "Noto Sans SC"))
  (defvar symbol-font (first-avail-font "Segoe UI Symbol" "Apple Symbols" "Noto Sans Symbols"))

  (set-face-attribute 'fixed-pitch nil :font monospace-font :height 120 :weight 'regular)
  (set-face-attribute 'variable-pitch nil :font serif-font :height 120 :weight 'regular)
  (set-face-attribute 'default nil :font monospace-font :height 120 :weight 'regular)

  (dolist (charset '(kana han cjk-misc bopomofo))
    (set-fontset-font t charset chinese-font))
  (set-fontset-font t 'symbol symbol-font nil 'prepend)

  ;; Set Emacs background
  (setq frame-background-mode 'light)

  (use-package solo-jazz-theme
    :config
    (load-theme 'solo-jazz t)))

;; Decorate modeline
(use-package spaceline
  :custom
  (powerline-default-separator 'arrow)
  :config
  (spaceline-emacs-theme))


;; revert buffers automatically when underlying files are changed externally
(use-package autorevert
  :config
  (global-auto-revert-mode 1)
  :delight auto-revert-mode)

;; recentf rembers your visited files
(use-package recentf
  :custom
  (recentf-max-saved-items 1500)
  (recentf-max-menu-items 15)
  (recentf-auto-cleanup 600)
  :config
  (add-to-list 'recentf-exclude (expand-file-name package-user-dir))
  (recentf-mode 1))


;; saveplace remembers your location in a file when saving files
(use-package saveplace
  :config
  ;; activate it for all buffers
  (save-place-mode 1))


;; savehist remembers minibuffer history
(use-package savehist
  :custom
  ;; search entries
  (savehist-additional-variables '(search-ring regexp-search-ring))
  ;; save every minute
  (savehist-autosave-interval 60)
  :config
  (savehist-mode 1))


(use-package helm
  :custom
  (helm-command-prefix-key         "C-c h")
  ;; open helm buffer inside current window, not occupy whole other window
  (helm-split-window-in-side-p           t)
  (helm-move-to-line-cycle-in-source     t)
  (helm-ff-search-library-in-sexp        t)
  (helm-ff-file-name-history-use-recentf t)
  ;; Enable fuzzy matching for buffer switching
  (helm-buffers-fuzzy-matching           t)
  ;; Display helm on top of window
  (helm-split-window-default-side   'above)
  (helm-echo-input-in-header-line        t)
  :config
  (require 'helm-config)
  (add-hook 'helm-minibuffer-set-up-hook #'helm-hide-minibuffer-maybe)
  (helm-mode 1)
  :bind
  (("M-x"       . 'helm-M-x)
   ("M-y"       . 'helm-show-kill-ring)
   ("C-x b"     . 'helm-mini)
   ("C-x C-b"   . 'helm-buffers-list)
   ("C-x C-f"   . 'helm-find-files)
   :map helm-map
   ("<tab>"     . 'helm-execute-persistent-action)
   ("C-i"       . 'helm-execute-persistent-action)
   ("C-z"       . 'helm-select-action)
   ("C-c C-l"   . 'helm-minibuffer-history)
   :map helm-command-map
   ("o"         . 'helm-occur))
  :delight helm-mode)


(use-package undo-tree
  :config
  (global-undo-tree-mode)
  :delight undo-tree-mode)


(use-package which-key
  :config
  (which-key-mode 1)
  :bind
  (("C-h C-k" . 'which-key-show-top-level))
  :delight which-key-mode)


(use-package paren-face
  :config
  (add-to-list 'paren-face-modes 'racket-mode)
  (set-face-foreground 'parenthesis "LightGray")
  (global-paren-face-mode 1))


(use-package smartparens
  :hook
  (smartparens-mode . (lambda ()
                        (when (member major-mode sp-lisp-modes)
                          (smartparens-strict-mode 1))))
  :config
  (require 'smartparens-config)
  ;; For lisp files we enable paredit-like structure editing
  (dolist (it sp-paredit-bindings)
    (define-key smartparens-strict-mode-map (read-kbd-macro (car it)) (cdr it)))
  (smartparens-global-mode 1)
  (show-smartparens-global-mode 1)
  :delight smartparens-mode)


;; Start server.
(require 'server)
(unless (server-running-p)
  (server-start))
