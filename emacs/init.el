(defvar EMACS_DIR "~/.emacs.d/")

(defvar efs/default-font-size 120)
(defvar efs/default-variable-font-size 120)

;; Disable certain things when in a graphical environment
(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)    ; Disable the toolbar
  (tooltip-mode -1)     ; Disable tooltips
  (menu-bar-mode -1))

; Set up the visible bell
(setq visible-bell t)

;;(load-theme 'wombat)

;(ido-mode 1)
;(setq ido-seperator "\n")

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(define-key emacs-lisp-mode-map (kbd "C-x M-t") 'counsel-load-theme)


;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" .   "https://orgmode.org/elpa/")
			 ("elpa" .  "https://elpa.gnu.org/packages/")))

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3") ; Fix loading of elpa archive

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Help Emacs to correctly load environment variables across operating systems
;;(use-package exec-path-from-shell :ensure t)
;;(exec-path-from-shell-initialize)

;;
;; Load platform specific variables using specific files. E.g linux.el. 
;; Make necessary changes as needed
(cond ((eq system-type 'windows-nt) (load (concat EMACS_DIR "windows")))
((eq system-type 'gnu/linux) (load (concat EMACS_DIR "linux")))
((eq system-type 'darwin) (load (concat EMACS_DIR "mac")))
(t (load-library "default")))

;; Basic setup
;; Set language environment to UTF-8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")
(use-package no-littering
  :init
;  (setq user-emacs-directory "~/.cache/emacs")
  :config
  (setq auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  )

(column-number-mode)
(global-display-line-numbers-mode t)

(set-face-attribute 'default nil :font "Fira Code Retina" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)

(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))


;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		treemacs-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-f" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("c-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (setq ivy-re-builders-alist '((swiper . ivy--regex-plus)
				(t . ivy--regex-fuzzy)))
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("M-C-j" . counsel-switch-buffer)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)  
  :config
  (counsel-mode 1))


(use-package ivy-prescient
  :after (counsel)
  :custom
  (ivy-prescient-enable-filtering t)
  :config
  (prescient-persist-mode 1)
  (ivy-prescient-mode 1))


(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts

(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 20)))

(use-package doom-themes
  :init
  ;(load-theme 'doom-dracula t))
  (load-theme 'doom-acario-dark t))
  
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package avy
  :ensure t
  :bind ("M-;" . avy-goto-char-timer))

(use-package magit
  ;:custom
  ;(magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  )

(use-package smartparens
  :config
  (smartparens-global-mode 1))

;; Projectile

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/workspaces")
    (setq projectile-project-search-path '("~/workspaces")))
  (setq projectile-switch-project-action #'projectile-dired))
  ;(projectile-register-project-type 'npm '("package.json")
;				  :project-file "package.json"
;				  :compile "npm install"
;				  :test "npm test"
;				  :run "npm start"
;				  :test-suffix ".spec")


(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))

;; Language server protocol mode support

;(setq lsp-java-jdt-download-url  "https://download.eclipse.org/jdtls/milestones/0.57.0/jdt-language-server-0.57.0-202006172108.tar.gz")

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")  ; Or 'C-l', 's-l'
  :hook
  (sh-mode . lsp)
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-bash-glob-pattern "*/*.sh")
  )

(use-package hydra)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package dap-mode
  :after lsp-mode
  :config (dap-auto-configure-mode)
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
)

(use-package lsp-java
  :mode "\\.java\\'"
  :config (add-hook 'java-mode 'lsp-deferred))

(use-package dap-java
  :ensure nil)

;(use-package helm-lsp)

;;(use-package helm
;;  :config (helm-mode))



(use-package company-box
  :hook (company-mode . company-box-mode))


;; Org Mode
(use-package org)

;; Make the customize interface store its config in a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)


;; Treat 'y' or <CR> as yes, 'n' as no.
(fset 'yes-or-no-p 'y-or-n-p)

(use-package dired
  :ensure nil
  :commands (dired  dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-aghov --group-directories-first"))
  )

;; Expand region
(use-package expand-region
  :bind ("C-=" . er/expand-region))


;; https://emacs.stackexchange.com/questions/265/how-to-auto-save-buffers-when-emacs-loses-focus
(defadvice switch-to-buffer (before save-buffer-now activate)
  (when (and buffer-file-name (buffer-modified-p)) (save-buffer)))
(defadvice other-window (before other-window-now activate)
  (when (and buffer-file-name (buffer-modified-p)) (save-buffer)))

;; When loosing focus
;; either save active buffer
(add-hook 'focus-out-hook 'save-buffer)
;; or save all open buffers
;;(add-hook 'focus-out-hook (lambda () (save-some-buffers t)))
