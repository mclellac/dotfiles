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

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/ikatyang/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(after! treesit
  (let ((cache-dir (expand-file-name ".local/cache/tree-sitter" user-emacs-directory))
        (extra-dir (expand-file-name "tree-sitter" user-emacs-directory)))
    (setq treesit-extra-load-path (list cache-dir extra-dir)))

  ;; Auto-install missing grammars
  (dolist (lang treesit-language-source-alist)
    (unless (treesit-language-available-p (car lang))
      (treesit-install-language-grammar (car lang))))

  (setq major-mode-remap-alist
        '((python-mode . python-ts-mode)
          (bash-mode   . bash-ts-mode)
          (sh-mode     . bash-ts-mode)
          (yaml-mode   . yaml-ts-mode)
          (json-mode   . json-ts-mode)
          (go-mode     . go-ts-mode)
          (rust-mode   . rust-ts-mode)
          (lua-mode    . lua-ts-mode)
          (c-mode      . c-ts-mode)
          (c++-mode    . c++-ts-mode))))

;; --- Python Query Patch (Final Clean Slate) ---
;; Completely replaces the built-in rules to avoid the crashing query bug in Emacs 30.2
(after! python
  (setq python-shell-interpreter "python3")
  (setq-default flycheck-python-pyright-executable "pyright")
  (setq +python-pyright-format-on-save t)
  (setq-hook! 'python-ts-mode-hook +format-with 'black)

  (setq python--treesit-settings
        (treesit-font-lock-rules
         :language 'python
         :feature 'keyword
         :override t
         '([
            "and" "as" "assert" "async" "await" "break" "case" "class" "continue"
            "def" "del" "elif" "else" "except" "exec" "finally" "for" "from"
            "global" "if" "import" "in" "is" "lambda" "match" "nonlocal" "not"
            "or" "pass" "print" "raise" "return" "try" "while" "with" "yield"
            ] @font-lock-keyword-face)

         :language 'python
         :feature 'definition
         :override t
         '((function_definition
            name: (identifier) @font-lock-function-name-face)
           (class_definition
            name: (identifier) @font-lock-type-face)
           (parameters (identifier) @font-lock-variable-name-face)
           (attribute attribute: (identifier) @font-lock-variable-name-face))

         :language 'python
         :feature 'assignment
         :override t
         '((assignment left: (identifier) @font-lock-variable-name-face)
           (assignment left: (attribute attribute: (identifier) @font-lock-variable-name-face)))

         :language 'python
         :feature 'string
         :override t
         '((string) @font-lock-string-face
           (interpolation (identifier) @font-lock-variable-name-face))

         :language 'python
         :feature 'comment
         :override t
         '((comment) @font-lock-comment-face))))

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
