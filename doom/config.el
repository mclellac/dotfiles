;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; User Information
(setq user-full-name ""
      user-mail-address "")

;; Fonts
(setq doom-font (font-spec :family "Adwaita Mono" :size 16 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Adwaita Mono" :size 14))

;; Theme
(setq doom-theme 'doom-nord)

;; Start Emacs fullscreen without a titlebar
(add-hook 'window-setup-hook #'toggle-frame-fullscreen)

;; Stop asking to quit
(setq confirm-kill-emacs nil)

;; Discover projects on launch
(setq projectile-project-search-path '("~/Projects/src/gitlab.nm.cbc.ca/"
                                       "~/Projects/src/github.com/mclellac")
      projectile-max-known-projects 100)

;; Line Numbers
(setq display-line-numbers-type t)

;; Org Mode Configuration
(setq org-directory "~/.org/")
(after! org
  (setq org-hide-emphasis-markers t
        org-insert-heading-respect-content nil
        org-log-done t
        org-log-into-drawer t))

;; Auto Save and Backup
(setq auto-save-default t
      make-backup-files t)

;; Modeline Configuration
(setq doom-modeline-enable-word-count t)

;; Wanderlust Email Client Configuration
(use-package! wanderlust
  :commands (wl wl-other-frame wl-draft)
  :config
  (setq elmo-imap4-default-server "imap.gmail.com"
        elmo-imap4-default-user "@gmail.com"
        elmo-imap4-default-authenticate-type 'clear
        elmo-imap4-default-port '993
        elmo-imap4-default-stream-type 'ssl
        elmo-imap4-use-modified-utf7 t
        wl-smtp-connection-type 'starttls
        wl-smtp-posting-port 587
        wl-smtp-authenticate-type "plain"
        wl-smtp-posting-user ""
        wl-smtp-posting-server "smtp.gmail.com"
        wl-local-domain "gmail.com"
        wl-default-folder "%inbox"
        wl-default-spec "%"
        wl-draft-folder "%[Gmail]/Drafts"
        wl-trash-folder "%[Gmail]/Trash"
        wl-folder-check-async t
        elmo-imap4-use-modified-utf7 t)
  (autoload 'wl-user-agent-compose "wl-draft" nil t)
  (if (boundp 'mail-user-agent)
      (setq mail-user-agent 'wl-user-agent))
  (if (fboundp 'define-mail-user-agent)
      (define-mail-user-agent
        'wl-user-agent
        'wl-user-agent-compose
        'wl-draft-send
        'wl-draft-kill
        'mail-send-hook)))

;; Custom Faces
(custom-set-faces!
  '(doom-dashboard-banner :inherit default)
  '(doom-dashboard-loaded :inherit default))
