;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       :completion
       (corfu +orderless)
       vertico +icons
       marginalia

       :ui
       color
       doom
       doom-dashboard
       doom-quit
       (emoji +unicode)
       hl-todo
       indent-guides
       ligatures
       modeline
       ophints
       (popup +defaults)
       tabs
       treemacs
       (vc-gutter +pretty)
       vi-tilde-fringe
       (window-select +numbers)
       workspaces
       zen

       :editor
       (evil +everywhere)
       avy
       file-templates
       fold
       (format +onsave)
       rotate-text
       snippets

       :emacs
       (dired +icons)
       electric
       eww
       (undo +tree)
       vc

       :term
       vterm

       :checkers
       syntax
       (spell +flyspell)

       :tools
       (ansible +lsp)
       direnv
       docker
       editorconfig
       (eval +overlay)
       (kubernetes +lsp)
       lsp
       lookup
       magit +forge
       make
       pdf
       (terraform +lsp)

       :os
       (:if (featurep :system 'macos) macos)

       :lang
       (cc +lsp)
       emacs-lisp
       (go +lsp)
       (json +lsp)
       (lua +lsp)
       (markdown +grip)
       (org +roam +journal +pomodoro +dragndrop)
       (python +lsp +pyright)
       qt
       rest
       (rust +lsp)
       (sh +lsp)
       (web +lsp)
       (yaml +lsp)

       :email
       (mu4e +org +gmail)

       :app
       (calendar +gcal)
       (rss +org)

       :config
       (default +bindings +smartparens))
