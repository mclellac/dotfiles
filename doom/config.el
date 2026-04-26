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

;; Set installation directory globally
(setq treesit-directory (expand-file-name ".local/cache/tree-sitter" user-emacs-directory))

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
  ;; Ensure directory exists for grammar installation
  (unless (file-directory-p treesit-directory)
    (make-directory treesit-directory t))
  
  (add-to-list 'treesit-extra-load-path treesit-directory)

  ;; Auto-install missing grammars safely
  (dolist (lang treesit-language-source-alist)
    (unless (treesit-language-available-p (car lang))
      (message "Treesit: Installing %s..." (car lang))
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
;; --- UI ENHANCEMENTS ---

;; Premium Typography: Italics for comments and Bold for keywords
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-doc-face :slant italic)
  '(font-lock-keyword-face :weight bold)
  '(font-lock-builtin-face :weight bold)
  ;; Make line numbers more subtle
  '(line-number :foreground "#4b5263")
  '(line-number-current-line :foreground "#51afef" :weight bold))

;; Dashboard Banner (Minimalist)
(setq fancy-splash-image (expand-file-name "wallpapers/mountains1.png" (file-name-directory load-file-name)))

(defun my-open-doom-config ()
  "Open the doom config file."
  (interactive)
  (find-file (expand-file-name "config.el" doom-user-dir)))

;; Functional Dashboard Menu
(setq +doom-dashboard-menu-sections
  '(("Recently opened files"
     :icon (nerd-icons-faicon "nf-fa-file_text_o" :face 'doom-dashboard-menu-title)
     :action recentf-open-files)
    ("Open project"
     :icon (nerd-icons-faicon "nf-fa-folder_open" :face 'doom-dashboard-menu-title)
     :action projectile-switch-project)
    ("Jump to bookmark"
     :icon (nerd-icons-faicon "nf-fa-bookmark" :face 'doom-dashboard-menu-title)
     :action bookmark-jump)
    ("Open org-agenda"
     :icon (nerd-icons-faicon "nf-fa-calendar" :face 'doom-dashboard-menu-title)
     :when (fboundp 'org-agenda)
     :action org-agenda)
    ("Edit emacs config"
     :icon (nerd-icons-faicon "nf-fa-wrench" :face 'doom-dashboard-menu-title)
     :action my-open-doom-config)))

;; Clean Window Dividers
(setq window-divider-default-places 'right-only
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(add-hook 'doom-first-input-hook #'window-divider-mode)

;; De-clutter: Hide line numbers in non-code buffers
(setq display-line-numbers-type t)
(dolist (mode '(org-mode-hook
                help-mode-hook
                vterm-mode-hook
                dired-mode-hook
                treemacs-mode-hook
                calendar-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Modeline tweaks
(after! doom-modeline
  (setq doom-modeline-height 30
        doom-modeline-bar-width 4
        doom-modeline-buffer-file-name-style 'truncate-with-project
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-lsp t
        doom-modeline-github t
        doom-modeline-env-version t))

;; Tab Bar (Centaur Tabs) Polish
(after! centaur-tabs
  (centaur-tabs-mode 1)
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'left
        centaur-tabs-gray-out-icons 'buffer)
  ;; Make tabs look cleaner
  (custom-set-faces!
    '(centaur-tabs-default :background "#1b2229" :foreground "#5b6268")
    '(centaur-tabs-selected :background "#282c34" :foreground "#bbc2cf" :weight bold)
    '(centaur-tabs-active-bar-face :background "#51afef")))

;; Dashboard Footer & Greeting
(defun my-dashboard-footer ()
  (insert "\n" (propertize "    Happy Hacking, mclellac!    " 'face 'font-lock-comment-face) "\n"))

(setq +doom-dashboard-functions
      '(doom-dashboard-widget-banner
        doom-dashboard-widget-shortmenu
        my-dashboard-footer
        doom-dashboard-widget-loaded))

;; Prettier Gutter (Fringe)
(set-fringe-mode 10)
(after! git-gutter
  (setq git-gutter:modified-sign "~"
        git-gutter:added-sign "+"
        git-gutter:deleted-sign "-"))

;; Custom colors for a cleaner look
(custom-set-faces!
  '(doom-modeline-bar :background "#51afef")
  '(mode-line :background "#1B2229" :foreground "#bbc2cf")
  '(mode-line-inactive :background "#21242b" :foreground "#5b6268"))

;; Transparency (Optional, but looks great with compositor)
(set-frame-parameter (selected-frame) 'alpha '(98 . 98))
(add-to-list 'default-frame-alist '(alpha . (98 . 98)))

;; Treemacs Customization
(after! treemacs
  (setq treemacs-width 30
        treemacs-position 'left
        treemacs-is-never-other-window t
        treemacs-silent-refresh t
        treemacs-sorting 'alphabetic-case-insensitive-asc)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

;; Indent Guides
(setq highlight-indent-guides-method 'character)

;; Rainbow Delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; --- WORKFLOW & NAVIGATION ENHANCEMENTS ---

;; File Manager (Dired) Polish
(after! dired
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-kill-when-opening-new-dired-buffer t)
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))

;; Minibuffer Search (Vertico)
(after! vertico
  (setq vertico-cycle t
        vertico-resize nil
        vertico-count 15))

;; Smooth Scrolling (Emacs 29+)
(pixel-scroll-precision-mode 1)

;; Keep 5 lines of context when scrolling near the top/bottom
(setq scroll-margin 5
      scroll-conservatively 5
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01)

;; Snappier Which-Key (shows keybinding hints faster)
(setq which-key-idle-delay 0.3)

;; Window Undo/Redo (use `SPC w u` to undo window changes)
(winner-mode 1)

;; Zen Mode (Writeroom) default width
(setq writeroom-width 100)

;; Better Autocomplete UI (Corfu)
(after! corfu
  ;; Show documentation popups alongside completions
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay 0.5)
  ;; Make corfu a bit more responsive
  (setq corfu-auto-delay 0.1
        corfu-auto-prefix 2))

;; --- MODERN UI FLOURISHES ---

;; Beacon: Pulse cursor after jumps/window switches
(after! beacon
  (beacon-mode 1)
  (setq beacon-color "#51afef"
        beacon-size 40
        beacon-blink-duration 0.3))

;; Org-Modern: Sleek icons/elements for Org Mode
(with-eval-after-load 'org
  (global-org-modern-mode)
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-all-regs t
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Appearance settings
   org-modern-star '("◉" "○" "◈" "◇" "✳")
   org-modern-list '((?- . "•") (?+ . "◦"))
   org-modern-tag t
   org-modern-priority t
   org-modern-todo t
   org-modern-table t
   org-modern-checkbox '((?X . "☑") (?\s . "☐") (?- . "❍"))))

;; Enhance search results visibility
(setq search-highlight t
      query-replace-highlight t)

;; Custom faces for better contrast
(custom-set-faces!
  ;; Make current search match more obvious
  '(isearch :background "#51afef" :foreground "#282c34" :weight bold)
  '(lazy-highlight :background "#223f5a" :foreground "#bbc2cf")
  ;; Prettier line highlighting
  '(hl-line :background "#2e3440"))

;; Minibuffer icons and info
(after! marginalia
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil)))

