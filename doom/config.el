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
        org-log-into-drawer t
        ;; Agenda settings
        org-agenda-files '("~/.org/inbox.org"
                           "~/.org/projects.org"
                           "~/.org/habits.org"
                           "~/.org/roam/")))

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

;; Visual and Safety Improvements
(setq vertico-resize t)
(setq-default delete-by-moving-to-trash t)

;; Org-Roam Configuration
(setq org-roam-directory (file-truename "~/.org/roam"))
(after! org-roam
  (org-roam-db-autosync-mode))

;; Quality of Life Improvements
(setq which-key-idle-delay 0.5) ;; Show keybindings faster

;; Smooth Scrolling
(setq scroll-margin 2
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Prettier Org-mode symbols
(after! org
  (setq org-ellipsis " ▼ "))

;; Python + Gnome/Libadwaita
(setq lsp-pyright-python-executable-cmd "python3")
(setq lsp-pyright-use-library-code-for-types t)

;; Kubernetes & Helm Charts
(add-to-list 'auto-mode-alist '("templates/.*\\.yaml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("templates/.*\\.yml\\'" . yaml-mode))

;; Terraform
(after! terraform-mode
  (setq terraform-format-on-save t))

;; Ansible
(after! ansible
  (setq ansible-vault-password-file "~/.ansible-vault-pass"))

;; Magit TODOs
(after! magit
  (magit-todos-mode 1))

;; Mixed Pitch (Variable-pitch for prose/comments)
(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

;; --- Productivity Hub Configuration ---

;; Org-Journal
(setq org-journal-dir "~/.org/journal/"
      org-journal-date-format "%A, %d %B %Y"
      org-journal-file-format "%Y-%m-%d.org")

;; Google Calendar Sync (Placeholder)
;; After 'doom sync', run 'M-x org-gcal-fetch' to authorize.
(setq org-gcal-client-id "YOUR_CLIENT_ID"
      org-gcal-client-secret "YOUR_CLIENT_SECRET"
      org-gcal-fetch-file-alist '(("user@gmail.com" . "~/.org/gcal.org")))

;; Pomodoro Sound
(after! org-pomodoro
  (setq org-pomodoro-play-sounds t))

;; Custom Captures (Quick notes/tasks)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/.org/inbox.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("n" "Note" entry (file+headline "~/.org/inbox.org" "Notes")
         "* %?\n  %i\n  %a")
        ("j" "Journal Entry" entry (file+datetree "~/.org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

;; --- Cloud, SecOps, and DevSecOps Configuration ---

;; VLF (Very Large Files)
(use-package! vlf
  :config
  (require 'vlf-setup))

;; Rainbow Delimiters (Universal clarity)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'conf-mode-hook #'rainbow-delimiters-mode)
(add-hook 'text-mode-hook #'rainbow-delimiters-mode)

;; Elfeed (Security Feeds via Org-mode)
(setq elfeed-org-files (list (expand-file-name "~/.org/elfeed.org")))
(use-package! elfeed-org
  :config
  (elfeed-org))

(after! elfeed
  (setq elfeed-search-filter "@2-weeks-ago +unread"))

;; --- Custom Keybindings ---
(map! :leader
      (:prefix ("o" . "open")
       :desc "Elfeed (RSS)" "R" #'=rss))

;; Avy Keybindings
(map! :leader
      :desc "Jump to char" "j" #'avy-goto-char-2)

;; Git Timemachine Keybinding
(map! :leader
      :desc "Git Timemachine" "g t" #'git-timemachine-toggle)
