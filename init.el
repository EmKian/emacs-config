;; -*- lexical-binding: t -*-
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
		  (lambda ()
			(message "Emacs loaded in %s."
					 (emacs-init-time))))
(add-hook 'emacs-startup-hook
		  (lambda ()
			(setq gc-cons-threshold (* 100 1024 1024))))
(savehist-mode)
(electric-pair-mode)
(global-visual-line-mode)
(winner-mode)
(add-hook 'prog-mode-hook (lambda ()(visual-line-mode -1)))
(setq cursor-type 'bar)
(set-fringe-style 8)
(set-face-attribute 'default nil :font "Iosevka Term" :height 170)
(set-face-attribute 'variable-pitch nil :font "Iosevka Aile" :height 170 :weight 'normal)
(setq-default
 byte-compile-warnings nil
 fill-column 80
 create-lockfiles nil
 sentence-end-double-space nil
 scroll-conservatively 1001
 fast-but-imprecise-scrolling t
 truncate-lines t
 show-trailing-whitespace nil
 custom-safe-themes t
 tab-width 4
 indent-tabs-mode t)

(setq make-backup-files t
	  backup-by-copying t
	  backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
	  auto-save-file-name-transforms `((".*" ,(concat user-emacs-directory "autosave/") t))
	  delete-old-versions t
	  kept-new-versions 6
	  kept-old-versions 3
	  version-control t)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq enable-recursive-minibuffers t)
(setq xref-show-definitions-function #'xref-show-definitions-buffer-at-bottom
      xref-show-xrefs-function #'xref-show-definitions-completing-read)

(setq read-process-output-max (* 1024 1024))

;; Straight bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package straight
  :custom
  (use-package-hook-name-suffix nil)
  (straight-use-package-by-default t)
  (straight-enable-use-package-integration t))

(defun beginning-of-line-toggle (arg)
  "Like `back-to-indentation', move point to first non-whitespace character of line.
Unlike 'back-to-indentation', if point is already there move it to the actual beginning of line, and viceversa.
Thus, this function sort of acts like a toggle between these two positions."
  (interactive "^p")
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
	(back-to-indentation)
	(when (= orig-point (point))
	  (move-beginning-of-line 1))))

(use-package recentf
  :defer t
  :init
  (recentf-mode))

(use-package general)

(use-package diminish)

(use-package server
  :when (display-graphic-p)
  :defer 1
  :config
  (unless (server-running-p)
	(server-start)))

(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t))

(use-package vertico-directory
  :straight nil
  :load-path "straight/repos/vertico/extensions"
  :after vertico
  :general
  (:keymaps 'vertico-map
			"C-j" 'vertico-next
			"C-k" 'vertico-previous
			"RET" 'vertico-directory-enter
			"DEL" 'vertico-directory-delete-char
			"M-DEL" 'vertico-directory-delete-word))

(use-package vertico-mouse
  :straight nil
  :load-path "straight/repos/vertico/extensions"
  :after vertico
  :config
  (vertico-mouse-mode))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
		completion-category-defaults nil
        completion-category-overrides '((files (style basic partial-completion)))))

  (use-package consult
  :general
  ("M-g g" 'consult-goto-line)
  ("C-c f r " 'consult-recent-file)
  ("C-x b" 'consult-buffer))

(use-package flycheck)

(use-package marginalia
  :after vertico
  :general
  (:keymaps 'minibuffer-local-map
			"M-A" 'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  :init
  (marginalia-mode))


(use-package yasnippet
  :init
  (yas-global-mode))

(use-package yasnippet-snippets)

(use-package consult-yasnippet
  :general
  (:keymaps 'lsp-mode-map
			"C-c l y" 'consult-yasnippet))

(use-package company)
  ;; :init
  ;; (setq company-tooltip-limit 14
  ;; 		company-minimum-prefix-length 2
  ;; 		company-tooltip-align-annotations t
  ;; 		company-frontends
  ;; 		'(company-pseudo-tooltip-frontend
  ;; 		  company-echo-metadata-frontend)
  ;; 		company-global-modes
  ;; 		'(not erc-mode
  ;; 			  message-mode
  ;; 			  eshell-mode
  ;; 			  vterm-mode))
  ;; :config
  ;; (setq company-idle-delay 0.3
  ;; 		company-tooltip-align-annotations t)
  ;; (global-company-mode))

;; (use-package company-posframe
;;   :after company
;;   :config
;;   (setq company-posframe-show-metadata nil
;; 		company-posframe-show-indicator nil)
;;   (company-posframe-mode))

(use-package corfu
  :config
  (setq corfu-auto t
		corfu-separator ?\s
		corfu-quit-at-boundary 'separator
		corfu-cycle t
		corfu-auto-prefix 3
		corfu-auto-delay 0.15
		corfu-max-width 110)
  :preface
  (defun corfu-enable-in-minibuffer ()
	"Enable Corfu in the minibuffer if `completion-at-point' is bound."
	(when (where-is-internal #'completion-at-point (list (current-local-map)))
      ;; (setq-local corfu-auto nil) Enable/disable auto completion
      (corfu-mode 1)))
  :hook
  (after-init-hook . global-corfu-mode)
  (minibuffer-setup-hook . corfu-enable-in-minibuffer))

(use-package corfu-doc
  :after corfu
  :hook
  (corfu-mode-hook . corfu-doc-mode)
  :config
  (setq corfu-doc-display-within-parent-frame t
		corfu-doc-delay 0.5
		corfu-doc-max-width 70
		corfu-doc-max-height 20)
  :general
  (:keymaps 'corfu-map
			"M-p" 'corfu-doc-scroll-down
			"M-n" 'corfu-doc-scroll-up
			"M-d" 'corfu-doc-toggle))
(unbind-key (kbd "M-c"))

(use-package popon
  :straight (popon :type git
							:repo "https://codeberg.org/akib/emacs-popon.git"))
(use-package corfu-terminal
  :straight (corfu-terminal :type git
							:repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :config
  (unless (display-graphic-p)
	(corfu-terminal-mode +1)))

(use-package corfu-doc-terminal
  :straight (corfu-doc-terminal
			 :type git
			 :repo "https://codeberg.org/akib/emacs-corfu-doc-terminal.git")
  :config
  (unless (display-graphic-p)
	(corfu-doc-terminal-mode +1)))
(use-package cape
  :straight t
  :general
  (:prefix "M-c"
		   "p" 'completion-at-point
		   "d" 'cape-dabbrev
		   "f" 'cape-file
		   "s" 'cape-symbol
		   "i" 'cape-ispell)
  :config
  (setq cape-dabbrev-min-length 3)
  (dolist (backend '(cape-symbol cape-keyword cape-file cape-dabbrev))
	(add-to-list 'completion-at-point-functions backend)))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l"
		lsp-completion-provider :none
		lsp-diagnostics-provider :flycheck)
  :preface
  (defun lsp-capf ()
	(setq-local completion-at-point-functions
				(list (cape-super-capf
					   #'lsp-completion-at-point
					   (cape-company-to-capf #'company-yasnippet)))
				completion-category-defaults nil))
  :hook
  ((c-mode-hook c++-mode-hook rust-mode-hook) . lsp)
  (lsp-completion-mode-hook . lsp-capf)
  :config
  (setq lsp-idle-delay 0.1
		lsp-headerline-breadcrumb-enable nil))


(use-package lsp-ui
  :hook (lsp-mode-hook . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-max-height 8
		lsp-ui-doc-max-width 72
		lsp-ui-doc-delay 0.5
		lsp-ui-doc-position 'at-point
		lsp-ui-sideline-show-hover nil))

;; (use-package eglot
;;   :preface
;;   (defun eglot-capf ()
;; 	(setq-local completion-at-point-functions
;; 				(list (cape-super-capf
;; 					   #'eglot-completion-at-point
;; 					   (cape-company-to-capf #'company-yasnippet)))))
;;   :hook
;;   (eglot-managed-mode-hook . eglot-capf)
;;   ;; (eglot-connected-hook . (lambda() (setq eldoc-documentation-strategy 'eldoc-documentation-compose)))
;;   :config
;;   (setq completion-category-defaults nil)
;;   (add-to-list 'completion-category-overrides '(eglot (styles orderless))))

(use-package ibuffer
  :general
  (:keymaps 'global-map
			"C-x C-b" 'ibuffer )
  :config
  (define-ibuffer-column size
    (:name "Size" :inline t :header-mouse-map ibuffer-size-header-map)
    (file-size-human-readable (buffer-size))))

(use-package vterm
  :config
  (setq vterm-timer-delay 0.01))

(use-package vterm-toggle
  :after vterm)

(use-package which-key
  :diminish which-key-mode
  :init
  (setq which-key-idle-delay 1.0
		which-key-idle-secondary-delay 0.4
		which-key-popup-type 'minibuffer)
  :hook
  (after-init-hook . which-key-mode))

(use-package embark)

(use-package expand-region)

(use-package tex
  :straight auctex)

(use-package rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(use-package org
  :preface
  (defun org-mode-<>-syntax-fix (start end)
	"Change syntax of characters ?< and ?> to symbol within source code blocks."
	(let ((case-fold-search t))
      (when (eq major-mode 'org-mode)
		(save-excursion
          (goto-char start)
          (while (re-search-forward "<\\|>" end t)
			(when (save-excursion
					(and
					 (re-search-backward "[[:space:]]*#\\+\\(begin\\|end\\)_src\\_>" nil t)
					 (string-equal (downcase (match-string 1)) "begin")))
              ;; This is a < or > in an org-src block
              (put-text-property (point) (1- (point))
								 'syntax-table (string-to-syntax "_"))))))))

  (defun org-setup-<>-syntax-fix ()
	"Setup for characters ?< and ?> in source code blocks.
Add this function to `org-mode-hook'."
	(make-local-variable 'syntax-propertize-function)
	(setq syntax-propertize-function 'org-mode-<>-syntax-fix)
	(syntax-propertize (point-max)))
  :config
  (setq org-directory "~/Documents/org"
		org-startup-indented t
		org-hide-leading-stars t
		org-return-follows-link t
		org-descriptive-links t
		org-startup-folded nil
		org-pretty-entities t
		org-clock-sound (concat user-emacs-directory "bell.wav"))
  (add-to-list 'org-modules 'org-habit t)

  (add-hook 'org-mode-hook #'org-setup-<>-syntax-fix)
  :hook
  (org-mode-hook . (lambda() (face-remap-add-relative 'tree-sitter-hl-face:punctuation '(:inherit 'org-block)))))
  
(use-package org-agenda
  :straight nil
  :config
  (setq org-agenda-files "~/Documents/org/agenda/agenda.org")
  :general
  ("C-c a" 'org-agenda))

(use-package org-journal
  :after org
  :config
  (setq org-journal-dir "~/Documents/org/journal"
		org-journal-date-format "%A, %F"))

(use-package org-roam
  :config
  (setq org-roam-directory (file-truename "~/Documents/org-roam"))
  (org-roam-db-autosync-mode))

(use-package ace-window
  :general
  ("M-o" 'ace-window))

(use-package doom-themes
  :config
  (doom-themes-org-config))

(use-package kaolin-themes)

(use-package modus-themes
  :init
  (setq modus-themes-syntax '(faint green-strings yellow-comments)
		modus-themes-subtle-line-numbers t
		modus-themes-region '(bg-only)
		modus-themes-links '(bold back)
		modus-themes-bold-constructs t
		modus-themes-italic-constructs nil
		modus-themes-lang-checkers '(faint)
		modus-themes-org-blocks 'gray-background
		modus-themes-paren-match '(bold)
		modus-themes-hl-line '(intense)
		modus-themes-mixed-fonts nil
		modus-themes-vivendi-color-overrides
		'((bg-main . "#181818")
		  (fg-main . "#FAFAFA"))
		modus-themes-operandi-color-overrides
		'((bg-main . "#FAFAFA")
		  (fg-main . "#101010")))
  :config
  (load-theme 'modus-vivendi))


(use-package tree-sitter-langs)

(use-package tree-sitter
  :init
  (global-tree-sitter-mode)
  :hook
  ('tree-sitter-after-on-hook . 'tree-sitter-hl-mode))

(use-package erc
  :config
  (setq erc-spelling-mode 1)
  (set 'erc-modules
	   '(autojoin
		 button
		 completion
		 fill
		 irccontrols
		 list
		 log
		 match
		 menu
		 move-to-prompt
		 netsplit
		 networks
		 noncommands
		 readonly
		 ring
		 stamp
		 spelling
		 track)))


(dolist (mode '(org-mode-hook
				term-mode-hook
				vterm-mode-hook
				eshell-mode-hook
				shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package ispell
  :config
  (setq ispell-dictionary "en-custom"))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(use-package helpful
  :straight t
  :general
  ("C-h F" 'helpful-function
   "C-h K" 'helpful-key
   "C-h V" 'helpful-variable
   "C-h ." 'helpful-at-point))

(use-package meow
  :init
  (setq meow-use-cursor-position-hack t)
  (defun end-of-visual-line-p ()
	(= (point)
	   (save-excursion
		 (end-of-visual-line)
		 (point))))
  (defun meow-append ()
	"Move to the end of selection, switch to INSERT state."
	(interactive)
	(if meow--temp-normal
		(progn
          (message "Quit temporary normal mode")
          (meow--switch-state 'motion))
      (if (not (region-active-p))
          (when (and meow-use-cursor-position-hack
					 (< (point) (point-max)))
			(unless (end-of-visual-line-p)
			  (forward-char 1)))
		(meow--direction-forward)
		(meow--cancel-selection))
      (meow--switch-state 'insert)))
  (defun meow-setup ()
	(setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
	(meow-motion-overwrite-define-key
	 '("j" . meow-next)
	 '("k" . meow-prev)
	 '("<escape>" . ignore))
	(meow-leader-define-key
	 ;; SPC j/k will run the original command in MOTION state.
	 '("j" . "H-j")
	 '("k" . "H-k")
	 ;; Use SPC (0-9) for digit arguments.
	 '("1" . meow-digit-argument)
	 '("2" . meow-digit-argument)
	 '("3" . meow-digit-argument)
	 '("4" . meow-digit-argument)
	 '("5" . meow-digit-argument)
	 '("6" . meow-digit-argument)
	 '("7" . meow-digit-argument)
	 '("8" . meow-digit-argument)
	 '("9" . meow-digit-argument)
	 '("0" . meow-digit-argument)
	 '("/" . meow-keypad-describe-key)
	 '("?" . meow-cheatsheet))
	(meow-normal-define-key
	 '("0" . meow-expand-0)
	 '("9" . meow-expand-9)
	 '("8" . meow-expand-8)
	 '("7" . meow-expand-7)
	 '("6" . meow-expand-6)
	 '("5" . meow-expand-5)
	 '("4" . meow-expand-4)
	 '("3" . meow-expand-3)
	 '("2" . meow-expand-2)
	 '("1" . meow-expand-1)
	 '("-" . negative-argument)
	 '(";" . meow-reverse)
	 '("," . meow-inner-of-thing)
	 '("." . meow-bounds-of-thing)
	 '("[" . meow-beginning-of-thing)
	 '("]" . meow-end-of-thing)
	 '("a" . meow-append)
	 '("A" . meow-open-below)
	 '("b" . meow-back-word)
	 '("B" . meow-back-symbol)
	 '("c" . meow-change)
	 '("d" . meow-delete)
	 '("D" . meow-backward-delete)
	 '("e" . meow-next-word)
	 '("E" . meow-next-symbol)
	 '("f" . meow-find)
	 '("g" . meow-cancel-selection)
	 '("G" . meow-grab)
	 '("h" . meow-left)
	 '("H" . meow-left-expand)
	 '("i" . meow-insert)
	 '("I" . meow-open-above)
	 '("j" . meow-next)
	 '("J" . meow-next-expand)
	 '("k" . meow-prev)
	 '("K" . meow-prev-expand)
	 '("l" . meow-right)
	 '("L" . meow-right-expand)
	 '("m" . meow-join)
	 '("n" . meow-search)
	 '("o" . meow-block)
	 '("O" . meow-to-block)
	 '("p" . meow-yank)
	 '("q" . meow-quit)
	 '("Q" . meow-goto-line)
	 '("r" . meow-replace)
	 '("R" . meow-swap-grab)
	 '("s" . meow-kill)
	 '("t" . meow-till)
	 '("u" . meow-undo)
	 '("U" . meow-undo-in-selection)
	 '("v" . meow-visit)
	 '("w" . meow-mark-word)
	 '("W" . meow-mark-symbol)
	 '("x" . meow-line)
	 '("X" . meow-goto-line)
	 '("y" . meow-save)
	 '("Y" . meow-sync-grab)
	 '("z" . meow-pop-selection)
	 '("'" . repeat)
	 '("<escape>" . ignore)))
  :config
  (meow-setup)
  (meow-global-mode)
  (defun meow--quit-corfu ()
	(when corfu--candidates
	  (corfu-quit)))
  (add-hook 'meow-insert-exit-hook #'meow--quit-corfu))

(use-package avy
  :config
  (meow-define-keys
	  'normal
 	'("\\" . avy-goto-char-timer)
	'("|" . avy-goto-char-2)))

(use-package vundo)

(use-package rust-mode)

(use-package rustic
  :after rust-mode
  :config
  (setq rustic-lsp-client 'lsp-mode))

(use-package doom-modeline
  :config
  (setq doom-modeline-major-mode-icon t
		doom-modeline-major-mode-color-icon nil
		doom-modeline-icon t
		doom-modeline-modal-icon t))
  
(use-package eldoc
  :config
  (setq eldoc-idle-delay 0.8))

(use-package eldoc-box
  :after eldoc
  :config
  (eldoc-box-hover-at-point-mode))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode))

(use-package popper
  :config
  (setq popper-reference-buffers
		'("\\*Messages\\*"
		  vterm-mode))
  (popper-mode)
  (popper-echo-mode))

(use-package nov)

(use-package flyspell
  :config
  (setq flyspell-issue-message-flag nil
		flyspell-issue-welcome-flag nil)
  :hook
  (org-mode-hook . flyspell-mode))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map
			  ("C-." . flyspell-correct-wrapper)))

(defun insert-date ()
  "Insert today's date a point"
  (interactive "*")
  (insert (format-time-string "%F")))
