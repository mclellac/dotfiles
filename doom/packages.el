;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or

;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
(package! vcl-mode)
(package! spacemacs-theme)
(package! adwaita-dark-theme)
(package! modus-themes)

;; Productivity & Aesthetics
(package! magit-todos)
(package! mixed-pitch)

;; Cloud, SecOps, and DevSecOps Tools
(package! git-timemachine)
(package! vlf)
(package! rainbow-delimiters)

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)
