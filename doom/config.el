;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; User Information
(setq user-full-name ""
      user-mail-address "")

(setq mu4e-maildir "/home/mclellac/.local/share/mail/personal")

;; Fonts
(setq doom-font (font-spec :family "Adwaita Mono" :size 16 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Adwaita Mono" :size 14))

;; Theme
(setq doom-theme 'doom-material)

;; Start Emacs fullscreen without a titlebar
;;(add-hook 'window-setup-hook #'toggle-frame-fullscreen)

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

;; mu4e Email Client Configuration
(after! mu4e
  (setq mu4e-update-interval (* 10 60)
        mu4e-get-mail-command "mbsync -a"
        mu4e-index-update-error-continue t
        mu4e-attachment-dir "~/Downloads"
        mu4e-change-filenames-when-moving t
        ;; Sending mail configuration
        sendmail-program (executable-find "msmtp")
        send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail)

  ;; Configure contexts
  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "Personal"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address  . "user@gmail.com")
                  (user-full-name     . "")
                  (mu4e-sent-folder   . "/[Gmail]/Sent Mail")
                  (mu4e-drafts-folder . "/[Gmail]/Drafts")
                  (mu4e-trash-folder  . "/[Gmail]/Bin")
                  (mu4e-refile-folder . "/[Gmail]/All Mail")
                  (mu4e-maildir-shortcuts . (("/INBOX"               . ?i)
                                             ("/[Gmail]/Sent Mail"   . ?s)
                                             ("/[Gmail]/Trash"       . ?t)
                                             ("/[Gmail]/All Mail"    . ?a)
                                             ("/[Gmail]/Starred"     . ?r)
                                             ("/[Gmail]/Drafts"      . ?d))))))))

;; Custom Faces
(custom-set-faces!
  '(doom-dashboard-banner :inherit default)
  '(doom-dashboard-loaded :inherit default))
