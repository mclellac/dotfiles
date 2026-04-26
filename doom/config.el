;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; --- CRITICAL: GLOBAL TREESIT INIT (Emacs 30) ---
;; Must be at the top to ensure all modes see it immediately
(setq treesit-extra-load-path '("/usr/lib/tree_sitter"))
(setq-default treesit-font-lock-level 4)

;; Force TS modes globally via auto-mode-alist (higher priority than remapping)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.sh\\'" . bash-ts-mode))
(add-to-list 'auto-mode-alist '("\\.bash\\'" . bash-ts-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

;; Remap for good measure
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (bash-mode   . bash-ts-mode)
        (sh-mode     . bash-ts-mode)
        (yaml-mode   . yaml-ts-mode)
        (json-mode   . json-ts-mode)
        (c-mode      . c-ts-mode)
        (c++-mode    . c++-ts-mode)))

;; --- Fix for Buffer Switching / Explorer Lag ---
(defun +treesit-force-refresh-hl-h ()
  "Force treesit to re-index and paint the buffer."
  (when (and (bound-and-true-p treesit-font-lock-settings)
             (derived-mode-p 'prog-mode))
    (treesit-font-lock-recompute-features)
    (font-lock-flush)
    (font-lock-ensure)))

;; Run refresh on file open and buffer switch
(add-hook 'find-file-hook #'+treesit-force-refresh-hl-h)
(add-hook 'window-buffer-change-functions (lambda (_) (+treesit-force-refresh-hl-h)))

;; User Information
(setq user-full-name ""
      user-mail-address "")

(setq mu4e-maildir "/home/mclellac/.local/share/mail/personal")

;; Fonts
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 20 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Hack" :size 18))

;; Theme
(setq doom-theme 'doom-one)

;; Stop asking to quit
(setq confirm-kill-emacs nil)

;; Discover projects on launch
(setq projectile-project-search-path '("~/Projects/src/bitbucket.org/cbc-digital"
                                       "~/Projects/src/github.com/mclellac")
      projectile-max-known-projects 200)

;; Line Numbers
(setq display-line-numbers-type t)

;; Org Mode Configuration
(setq org-directory "~/.org/")
(after! org
  (setq org-hide-emphasis-markers t
        org-agenda-files '("~/.org/inbox.org"
                           "~/.org/projects.org"
                           "~/.org/habits.org"
                           "~/.org/roam/")))

;; --- LSP & PERFORMANCE ---
(after! lsp-mode
  ;; DISABLE semantic tokens - instant highlighting comes from Tree-sitter.
  ;; Semantic tokens are what make it "slow as fuck".
  (setq lsp-semantic-tokens-enable nil)
  (setq lsp-idle-delay 0.1
        lsp-headerline-breadcrumb-enable nil)
  
  ;; Ensure TS modes trigger LSP
  (add-to-list 'lsp-language-id-configuration '(python-ts-mode . "python"))
  (add-to-list 'lsp-language-id-configuration '(bash-ts-mode . "sh"))
  (add-to-list 'lsp-language-id-configuration '(yaml-ts-mode . "yaml")))

;; --- Python Specifics ---
(after! python
  (setq python-shell-interpreter "python3")
  (setq-default flycheck-python-pyright-executable "pyright")
  (setq +python-pyright-format-on-save t)
  (setq-hook! 'python-ts-mode-hook +format-with 'black))

;; Shell
(after! sh-script
  (setq-hook! 'bash-ts-mode-hook +format-with 'shfmt))

;; Markdown
(after! markdown-mode
  (setq markdown-command "grip --export -"
        markdown-open-command "grip")
  (setq-hook! 'markdown-mode-hook +format-with 'prettier))

;; Mixed Pitch
(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

;; Rainbow Delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
