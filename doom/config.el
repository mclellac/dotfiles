;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

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

;; --- NATIVE TREE-SITTER (Emacs 30) ---
(setq-default treesit-font-lock-level 4)

(after! treesit
  (setq treesit-extra-load-path (list (expand-file-name "tree-sitter" user-emacs-directory)))
  
  (setq major-mode-remap-alist
        '((python-mode . python-ts-mode)
          (bash-mode   . bash-ts-mode)
          (sh-mode     . bash-ts-mode)
          (yaml-mode   . yaml-ts-mode)
          (json-mode   . json-ts-mode)
          (c-mode      . c-ts-mode)
          (c++-mode    . c++-ts-mode))))

;; --- Python Query Patch ---
;; This aggressively fixes the "Syntax error at 358" by redefining the failing rule
(after! python
  (setq python-shell-interpreter "python3")
  (setq-default flycheck-python-pyright-executable "pyright")
  (setq +python-pyright-format-on-save t)
  (setq-hook! 'python-ts-mode-hook +format-with 'black)

  ;; Define the corrected keywords list and rule
  (let ((keywords '("as" "assert" "async" "await" "break" "case" "class" "continue" 
                    "def" "del" "elif" "else" "except" "exec" "finally" "for" 
                    "from" "global" "if" "import" "lambda" "match" "nonlocal" 
                    "pass" "print" "raise" "return" "try" "while" "with" "yield" 
                    "and" "in" "is" "not" "or")))
    (setq python--treesit-settings
          (append python--treesit-settings
                  (treesit-font-lock-rules
                   :language 'python
                   :feature 'keyword
                   :override t
                   `([,@keywords] @font-lock-keyword-face
                     ((identifier) @font-lock-keyword-face
                      (:match "^self$" @font-lock-keyword-face))))))))

;; --- LSP & PERFORMANCE ---
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t)
  (setq lsp-idle-delay 0.1
        lsp-headerline-breadcrumb-enable nil)
  
  (add-to-list 'lsp-language-id-configuration '(python-ts-mode . "python"))
  (add-to-list 'lsp-language-id-configuration '(bash-ts-mode . "sh"))
  (add-to-list 'lsp-language-id-configuration '(yaml-ts-mode . "yaml")))

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
