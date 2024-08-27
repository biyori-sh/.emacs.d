;;; init.el --- My init.el -*- lexical-binding: t -*-

;; ( cd ~/.emacs.d && emacs --batch -f batch-byte-compile init.el )

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("elpa" . "http://tromey.com/elpa/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))
  (leaf leaf-keywords :ensure t
	:init
	;; optional packages if you want to use.
	(leaf el-get :ensure t)
	:config
	;; initialize leaf-keywords.el
	(leaf-keywords-init)))

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf server :ensure t :require t
  :when (window-system)
  :doc "Run the emacs-client server"
  :config
  (unless (server-running-p)
    (server-start)))

(leaf slime :ensure t
  ;; Install Homebrew for linux
  ;; "brew install roswell && ros setup && ros install slime"
  ;; After helper.el is loaded, more functions are available in elisp.
  :doc "SLIME for Common Lisp"
  :mode (("\\.lisp$" . lisp-mode))
  :preface (load (expand-file-name "~/.roswell/helper.el"))
  :custom ((slime-net-coding-system . 'utf-8-unix))
  :config
  ;; (slime-setup '(slime-fancy slime-banner slime-company)) ;package-install: slime-company
  (add-to-list 'slime-lisp-implementations
               '(sbcl ("ros" "-L" "sbcl-bin" "-Q" "dynamic-space-size=8192" "run"))))

(leaf custom-file
  :doc "Set custom.el for variables and faces."
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf cus-properties
  :doc "Define customization properties of builtins."
  :tag "builtin" "internal"
  :preface
  (defun open-init ()
    "Open the init file."
    (interactive)
    (find-file "~/.emacs.d/init.el"))
  :custom ((user-mail-address . "shimojihiromu@gmail.com")
           (user-login-name . "biyori-sh")
           (create-lockfiles . nil)
           (debug-on-error . t)
           (init-file-debug . t)
           (frame-resize-pixelwise . t)
           (enable-recursive-minibuffers . t)
           (history-length . 1000)
           (history-delete-duplicates . t)
           (scroll-bar-mode . nil)
           (scroll-preserve-screen-position . t)
           (scroll-conservatively . 100)
           (mouse-wheel-scroll-amount . '(1 ((control) . 5)))
           (ring-bell-function . 'ignore)
           (text-quoting-style . 'straight)
           (truncate-lines . nil)
           ;; (use-dialog-box . nil)
           ;; (use-file-dialog . nil)
           (menu-bar-mode . nil)
           (tool-bar-mode . nil)
           (indent-tabs-mode . nil)
           (tab-width . 4)
           (inhibit-startup-screen . t)
           (save-place-mode . t)
           (column-number-mode . t)
           (line-number-mode . t)
           (blink-cursor-mode . nil)
           (size-indication-mode . t)
           (auto-image-file-mode . t)
           (show-trailing-whitespace . t)
           ;; (global-linum-mode . t)     ;display line numbers
           ;; (setq frame-title-format . "%f")
           (frame-title-format . "%b %f %& %Z"))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)     ;yes/no -> y/n
  (define-key key-translation-map [?\C-h] [?\C-?]) ;backspace
  (global-set-key (kbd "M-?") 'help-for-help)
  (global-set-key (kbd "C-c l") 'toggle-truncate-lines)
  ;; (global-set-key (kbd "C-x <SPC>") 'set-mark-command)
  (dolist (key '("C-@" ;; set-mark-command
                 ))
    (global-unset-key (kbd key)))
  ;; save flies +x if it's starts with #!
  (add-hook 'after-save-hook
            'executable-make-buffer-file-executable-if-script-p)
  ;; highlight of current line
  (global-hl-line-mode t)
  (leaf garbage-collection
    :custom
    ;; Increase threshold to fire garbage collection
    ((gc-cons-threshold . 1073741824)
     (garbage-collection-messages . t))
    :config
    ;; Run GC every 60 seconds if emacs is idle.
    (run-with-idle-timer 60.0 t #'garbage-collect))
  (leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 1))
  :global-minor-mode global-auto-revert-mode)
  (leaf delete-selection
    :doc "Delete the selection if you insert."
    :tag "builtin"
    :global-minor-mode delete-selection-mode)
  (leaf parenthesis
    :doc "highlight matching parenthesis"
    :tag "builtin"
    :custom ((show-paren-delay . 0)
             (show-paren-style . 'parenthesis)) ;; or 'expression
    :global-minor-mode show-paren-mode)
  (leaf simple
    :doc "basic editing commands for Emacs"
    :tag "builtin" "internal"
    :custom ((kill-ring-max . 100)
             (kill-read-only-ok . t)
             (kill-whole-line . t)
             (eval-expression-print-length . nil)
             (eval-expression-print-level . nil)))
  (leaf auto-save-backup-files
    :doc "Settings for auto-save files and backup files"
    :tag "builtin"
    :custom `((auto-save-timeout . 15)
              (auto-save-interval . 60)
              (auto-save-file-name-transforms . '((".*" ,(locate-user-emacs-file "backup/") t)))
              (backup-directory-alist . '((".*" . ,(locate-user-emacs-file "backup"))
                                          (,tramp-file-name-regexp . nil)))
              (version-control . t)
              (delete-old-versions . t)
              (create-lockfiles . nil)))
  (leaf startup
    :doc "Process Emacs shell arguments."
    :tag "builtin" "internal"
    :custom `((auto-save-list-file-prefix . ,(locate-user-emacs-file "backup/.saves-")))))

(leaf funcs-f/w/b
  :doc "Functions for frame, window and buffer."
  :preface
  (progn
    ;; Windows11がフレーム（ウィンドウ）の調整に対応したためコメントアウト
    ;; (defun resize-frame ()
    ;;   "Resize the selected frame."
    ;;   (interactive)
    ;;   (message "please select: l(Left) or r(Right) or a(All of the screen).")
    ;;   (let ((char (read-char-exclusive)))
    ;;     (cond ((= char ?l)
    ;;            (set-frame-position (selected-frame) 0 0)
    ;;            (set-frame-size (selected-frame) 932 988 t))
    ;;           ((= char ?r)
    ;;            (set-frame-position (selected-frame) 960 0)
    ;;            (set-frame-size (selected-frame) 932 988 t))
    ;;           ((= char ?a)
    ;;            (set-frame-position (selected-frame) 0 0)
    ;;            (set-frame-size (selected-frame) 1892 988 t))
    ;;           (t (message "Quit")))))
    (defun prev-window ()
      "Select previous window."
      (interactive)
      (other-window -1))
    (defun window-resizer ()
      "Resize the current window with moving edges to left(h), below(j),
       above(k) and right(l)."
      (interactive)
      (let ((window-obj (selected-window))
            (current-width (window-width))
            (current-height (window-height))
            (dx (if (= (nth 0 (window-edges)) 0) 1 -1))
            (dy (if (= (nth 1 (window-edges)) 0) 1 -1))
            c)
        (catch 'end-flag
          (while t
            (message "size[%dx%d]"
                     (window-width) (window-height))
            (setq c (read-char-exclusive))
            (cond ((= c ?l) (enlarge-window-horizontally dx))
                  ((= c ?h) (shrink-window-horizontally dx))
                  ((= c ?j) (enlarge-window dy))
                  ((= c ?k) (shrink-window dy))
                  (t (message "Quit")
                     (throw 'end-flag t))))))))
  :config
  ;; resize the selected frame
  ;; (global-set-key (kbd "C-c f") 'resize-frame)
  ;; resize the current window
  (global-set-key (kbd "C-c r") 'window-resizer)
  ;;change the current buffer
  (global-set-key (kbd "<C-tab>") 'next-buffer)
  (global-set-key (kbd "C-c <C-tab>") 'previous-buffer)
  ;; move to the next/previous window
  (global-set-key (kbd "C-'") 'other-window)
  (define-key global-map (kbd "C-\"") 'prev-window))

(leaf jp-env
  :doc "Settings for Japanese environment."
  :config
  ;; language environment
  (set-language-environment "Japanese")
  ;; coding system
  (set-terminal-coding-system 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8)
  (leaf mozc-im :ensure t :require t    ; mozc -> mozc-im
    ;; Input method for Japanese
    ;; "sudo apt install emacs-mozc emacs-mozc-bin"
    :doc "Input method: Mozc."
    :preface
    (require 'mozc-popup)               ; "popup" is available in "mozc-candidate-style"
    :custom
    ((default-input-method . "japanese-mozc-im") ; japanese-mozc -> japanese-mozc-im
     (mozc-candidate-style . 'popup))) ; overlay, echo-area, popup
  (leaf migemo :ensure t :require t
    ;; "sudo apt install cmigemo elpa-migemo"
    :doc "Provides Japanese increment search."
    :custom ((migemo-command . "cmigemo")
             (migemo-options . '("-q" "--emacs"))
             (migemo-dictionary . "/usr/share/cmigemo/utf-8/migemo-dict")
             (migemo-user-dictionary . nil)
             (migemo-regex-dictionary . nil)
             (migemo-coding-system . 'utf-8-unix))
    :config
    (load-library "migemo")
    (migemo-init)))

(leaf fonts
  :doc "Properties for fonts."
  :when (display-graphic-p)             ; -nw or not
  :config
  ;; 半角英字設定
  ;; https://github.com/yuru7/HackGen
  (set-face-attribute 'default nil :family "HackGen Console NF" :height 200)
  ;; 全角かな設定
  (set-fontset-font (frame-parameter nil 'font)
                    'japanese-jisx0208
                    (font-spec :family "HackGen Console NF" :height 200))
  ;; 半角ｶﾅ設定
  (set-fontset-font (frame-parameter nil 'font)
                    'katakana-jisx0201
                    (font-spec :family "HackGen Console NF" :height 200)))

(leaf color-theme-modern :ensure t
  :doc "Activate the modern color theme."
  :custom-face
  (hl-line . '((t (:background "grey20"))))
  :config (progn
             ;; (load-theme 'deep-blue t t)
             ;; (enable-theme 'deep-blue))
             ;; (load-theme 'desert t t)
             ;; (enable-theme 'desert))
             (load-theme 'clarity t t)
             (enable-theme 'clarity)))

;; (leaf scrolling
;;   :doc "Configures for scrolling."
;;   :config
;;   ;; smooth-scroll
;;   (leaf smooth-scroll :ensure t :require t
;;     :config
;;     (smooth-scroll-mode t))
;;   (leaf smooth-scrolling :ensure t :require t
;;     :config
;;     (smooth-scrolling-mode t)))

(leaf undo
  :doc "undo-tree and undo-history"
  :config
  (leaf undo-tree :ensure t :require t
    :doc "Undo tree."
    :custom
    ((undo-tree-history-directory-alist . '(("." . "~/.emacs.d/undohist"))))
    :config
    (global-undo-tree-mode))
  (leaf undohist :ensure t :require t
    :doc "Remain the undo history even if the window is closed."
    :config
    (undohist-initialize)))

(leaf splelling
  :doc "Settings for spell-checkers"
  :config
  (leaf aspell
    ;; "sudo apt install aspell"
    :doc "spell checker"
    :custom ((ispell-program-name . "aspell"))
    :config
    (with-eval-after-load "ispell"
      (setq ispell-local-dictionary "en_US")
      (add-to-list 'ispell-skip-region-alist '("[^\000-\377]+"))))
  (leaf flyspell-mode
    :doc "Add hook: flyspell mode."
    :hook yatex-mode-hook org-mode-hook text-mode-hook)
  (leaf flyspell-prog-mode
    :doc "Add hook: flyspell-prog mode. Checking spells in comments and strings."
    :hook c-mode-common-hook emacs-lisp-mode-hook))

(leaf yatex :ensure t
  ;; Don't need to install yatex by using apt, just by using package-install in emacs.
  :doc "YaTeX mode"
  :commands yatex-mode
  :mode (("\\.tex$" . yatex-mode)
         ("\\.ltx$" . yatex-mode)
         ("\\.cls$" . yatex-mode)
         ("\\.sty$" . yatex-mode)
         ("\\.clo$" . yatex-mode)
         ("\\.bbl$" . yatex-mode))
  :custom
  ((YaTeX-inhibit-prefix-letter . t)     ; key-bind: "C-c " -> "C-c-"
   (YaTeX-kanji-code . nil)
   (YaTeX-latex-message-code . 'utf-8)
   (YaTeX-use-LaTeX2e . t)
   (YaTeX-use-AMS-LaTeX . t)
   ;; PDF preview
   (YaTeX-dvi2-command-ext-alist . '(("TeXworks\\|texworks\\|texstudio\\|mupdf\\|SumatraPDF\\|Preview\\|Skim\\|TeXShop\\|evince\\|atril\\|xreader\\|okular\\|zathura\\|qpdfview\\|Firefox\\|firefox\\|chrome\\|chromium\\|MicrosoftEdge\\|microsoft-edge\\|Adobe\\|Acrobat\\|AcroRd32\\|acroread\\|pdfopen\\|xdg-open\\|open\\|start\\|emacsclient" . ".pdf")))
   ;; for Windows, SumatraPDF.exe
   ;; (dvi2-command . "SumatraPDF.exe -reuse-instance")
   ;; (tex-pdfview-command . "SumatraPDF.exe -reuse-instance")
   ;; Emacsclient for PDF-tools
   ;; (dvi2-command . "emacsclient")
   ;; (tex-pdfview-command . "emacsclient")
   ;; Evince
   (dvi2-command . "evince")
   (tex-pdfview-command . "evince")
   ;; Okular
   ;; (dvi2-command . "okular --unique")
   ;; (tex-pdfview-command . "okular --unique")
   ;; properties for RefTeX
   (reftex-enable-partial-scans . t)
   (reftex-save-parse-info . t)
   (reftex-use-multiple-selection-buffers . t)
   ;; RefTeXにおいて数式の引用を\eqrefにする
   (reftex-label-alist . '((nil ?e nil "\\eqref{%s}" nil nil))))
  :config
  (with-eval-after-load 'yatexprc
    (defun YaTeX-preview-jump-line ()
      "Call jump-line function of various previewer on current main file"
      (interactive)
      (save-excursion
        (save-restriction
          (widen)
          (let* ((pf (or YaTeX-parent-file
                         (save-excursion (YaTeX-visit-main t) (buffer-file-name))))
                 (pdir (file-name-directory pf))
                 (bnr (substring pf 0 (string-match "\\....$" pf)))
                 ;; (cf (file-relative-name (buffer-file-name) pdir))
                 (cf (buffer-file-name)) ;2016-01-08
                 (buffer (get-buffer-create " *preview-jump-line*"))
                 (line (count-lines (point-min) (point-end-of-line)))
                 (previewer (YaTeX-preview-default-previewer))
                 (cmd (cond
                       ((string-match "Skim" previewer)
                        (format "%s %d '%s.pdf' '%s'"
                                YaTeX-cmd-displayline line bnr cf))
                       ((string-match "evince" previewer)
                        (format "%s '%s.pdf' %d '%s'"
                                "fwdevince" bnr line cf))
                       ((string-match "sumatra" previewer)
                        (format "%s \"%s.pdf\" -forward-search \"%s\" %d"
                                previewer bnr cf line))
                       ((string-match "zathura" previewer)
                        (format "%s --synctex-forward '%d:0:%s' '%s.pdf'"
                                previewer line cf bnr))
                       ((string-match "qpdfview" previewer)
                        (format "%s '%s.pdf#src:%s:%d:0'"
                                previewer bnr cf line))
                       ((string-match "okular" previewer)
                        (format "%s '%s.pdf#src:%d %s'"
                                previewer bnr line (expand-file-name cf)))
                       )))
            (YaTeX-system cmd "jump-line" 'noask pdir))))))
  ;; 70行程度で自動的に改行が挿入されるのを抑制
  (add-hook 'yatex-mode-hook '(lambda () (setq auto-fill-function nil)))
  ;; typeset
  (defun auto-type-set ()
    "LaTeX typeset."
    (goto-line 1)
    (let ((str nil)
          (prev-line-bol -1)
          (curr-line-bol (point-at-bol)))
      (while (/= prev-line-bol curr-line-bol)
        (setq prev-line-bol (point-at-bol))
        (setq str (buffer-substring-no-properties (point-at-bol) (point-at-eol)))
        ;; ;; tex ファイルの200文字目まで読み込んでstr にバインド
        ;; (if (ignore-errors (setq str (buffer-substring-no-properties 1 200))) nil
        ;;   ;; 200文字に満たない場合はファイル内の全文字をバインドし直す
        ;;   (setq str (buffer-string)))
        (cond
         ;; uplatex
         ((string-match "uplatex" str)
          (setq tex-command "latexmk -e '$latex=q/uplatex %O -synctex=1 -file-line-error %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -pdfdvi"))
         ;; platex
         ((string-match "platex" str)
          (setq tex-command "latexmk -e '$latex=q/platex %O -synctex=1 -file-line-error %S/' -e '$bibtex=q/pbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/mendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -pdfdvi"))
         ;; lualatex
         ((string-match "lualatex" str)
          (setq tex-command "latexmk -e '$lualatex=q/lualatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -pdflua"))
         ;; xelatex
         ((string-match "xelatex" str)
          (setq tex-command "latexmk -e '$xelatex=q/xelatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -pdfxe"))
         ;; pdflatex
         ((string-match "pdflatex" str)
          (setq tex-command "latexmk -synctex=1 -f -norc -pdf"))
         ;; -gg: 前の中間ファイルを消してからコンパイル
         ;; -norc: latexmkrc （引数外の別の設定ファイル） の読み込みをしない
         (t (forward-line)
            (setq curr-line-bol (point-at-bol)))))))
  (add-hook 'yatex-mode-hook 'auto-type-set)
  ;; RefTeXをYaTeXで使えるようにする
  (add-hook 'yatex-mode-hook '(lambda () (reftex-mode t)))
  ;; texファイルを開くと自動でRefTexモード
  (add-hook 'latex-mode-hook 'turn-on-reftex)
  ;; Outline-minor-mode適用
  (defun latex-outline-level ()
    (interactive)
    (let ((str nil))
      (looking-at outline-regexp)
      (setq str (buffer-substring-no-properties (match-beginning 0) (match-end 0)))
      (cond ;; キーワード に 階層 を返す
       ((string-match "documentclass" str) 1)
       ((string-match "documentstyle" str) 1)
       ((string-match "part" str) 2)
       ((string-match "chapter" str) 3)
       ((string-match "appendix" str) 3)
       ((string-match "subsubsection" str) 6)
       ((string-match "subsection" str) 5)
       ((string-match "section" str) 4)
       (t (+ 6 (length str)))
       )))
  (add-hook 'yatex-mode-hook
            '(lambda ()
               (setq outline-level 'latex-outline-level)
               (make-local-variable 'outline-regexp)
               (setq outline-regexp
                     (concat "[ \t]*\\\\\\(documentstyle\\|documentclass\\|"
                             "part\\|chapter\\|appendix\\|section\\|subsection\\|subsubsection\\)"
                             "\\*?[ \t]*[[{]"))
               (outline-minor-mode t)))
  ;; Outline-minor-modeのprefixを"C-c @"から"C-c-o"に変更
  (add-hook 'outline-minor-mode-hook
            (lambda () (local-set-key "\C-c\C-o"
                                      outline-mode-prefix-map))))

;;(leaf company :ensure t :require t
;;  :doc "A text completion framework for Emacs."
;;  :custom
;;  ((company-idle-delay . 0.3)
;;   (company-minimum-prefix-length . 2))
;;  :config
;;  (add-hook 'after-init-hook 'global-company-mode))

(leaf magit :ensure t :require t
  :doc "Magit"
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

(leaf cc-mode
  :doc "Major mode for editing C and similar languages."
  :tag "builtin"
  :defvar (c-basic-offset)
  :bind (c-mode-base-map
         ("C-c c" . compile))
  :mode-hook
  (c-mode-hook . ((c-set-style "bsd")
                  (setq c-basic-offset 4)))
  (c++-mode-hook . ((c-set-style "bsd")
                    (setq c-basic-offset 4))))

;; (leaf markdown-mode :ensure t :require t
;;   :doc "Major mode for Markdown."
;;   :mode (("\\.markdown$" . markdown-mode)
;;          ("\\.md$" . gfm-mode))
;;   :config
;;   (setq markdown-command "pandoc -t html5")
;;   (setq markdown-preview-stylesheets
;;         (list "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css")))

(leaf my-org
  :doc "Settings for org-mode"
  :custom (;; org-mode起動時の折り返し設定 （t：折り返さない、nil：折り返す）
           (org-startup-truncated . nil))
  :custom-face
  ((org-meta-line . '((nil (:height 200 :inherit 'font-lock-comment-face))))
   (org-date . '((nil (:height 200 :foreground "Cyan" :underline t))))
   (org-table . '((nil (:height 200 :foreground "LightSkyBlue"))))
   (org-block-begin-line . '((nil (:height 200 :inherit 'font-lock-comment-face))))
   (org-block . '((nil (:height 200 :inherit 'shadow))))
   (org-block-end-line . '((nil (:height 200 :inherit 'font-lock-comment-face))))
   (org-code . '((nil (:height 200 :inherit 'shadow)))))
  :config
  (leaf org-bullets :ensure t :require t
    :doc "Decorate org-mode."
    :config
    (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))
  (leaf org-tempo :require t
    :when (>= (string-to-number (org-version)) 9.2) ; package-list-packages: org gnu
    :doc "Insert structure templates:  <C-c-,> or shortcut key <s TAB, <c TAB, ...")
  (leaf ox-md :require t
    :doc "The option to convert to Markdown in org-export-dispatch."
    :after org)
  (leaf ox-latex :require t
    :doc "LaTeX for org-mode"
    :preface
    (defun org-mode-reftex-setup ()     ; RefTeX
      (load-library "reftex")
      (and (buffer-file-name)
           (file-exists-p (buffer-file-name))
           (reftex-parse-all))
      (define-key org-mode-map (kbd "C-c )") 'reftex-citation))
    :custom
    ((org-latex-default-class . "ltjsarticle")
     (org-latex-pdf-process . '("lualatex -interaction nonstopmode -output-directory %o %f"
                                "bibtex %b"
                                "lualatex -interaction nontopmode -output-directory %o %f"
                                "lualatex -interaction nonstopmode -output-directory %o %f")))
    :config
    (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
    (add-to-list 'org-latex-classes
                 '("ltjsarticle"
                   "\\documentclass[a4paper]{ltjsarticle}
                    \\usepackage{amsmath}
                    \\usepackage{amssymb}
                    \\usepackage{fixltx2e}
                    \\usepackage{graphicx}
                    \\usepackage{longtable}
                    \\usepackage{float}
                    \\usepackage{wrapfig}
                    \\usepackage{soul}
                    \\usepackage{color}
                    \\usepackage[usenames,svgnames,psnames]{xcolor}
                    \\usepackage[colorlinks,filecolor=FireBrick,linkcolor=mediumtealblue,urlcolor=blue,citecolor=Ao(English),linktocpage,bookmarksopenlevel=4]{hyperref}
                    \\usepackage{geometry}
                    \\geometry{margin=2cm,top=1.8cm,bottom=2.2cm}
                    \\definecolor{MidnightBlue}{rgb}{0.1, 0.1, 0.44}
                    \\definecolor{blue}{rgb}{0.0, 0.0, 1.0}
                    \\definecolor{Ao(English)}{rgb}{0.0, 0.5, 0.0}
                    \\definecolor{mediumtealblue}{rgb}{0.0, 0.33, 0.71}"
                    ("\\section{%s}" . "\\section*{%s}")
                    ("\\subsection{%s}" . "\\subsection*{%s}")
                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
    (add-hook 'org-mode-hook 'org-mode-reftex-setup))
  (leaf ox-bibtex :require t
    ;;"package-install: org-plus-contrib" and "sudo apt install bibtex2html"
    :doc "BibTeX for org-mode"
    :custom
    `((reftex-default-bibliography . '(,(expand-file-name "~/documents/phys/checked-papers/ref.bib")))))
  (leaf oride
  ;; Ref: https://nullprogram.com/blog/2013/02/06/#:~:text=The%20rest%20of%20define%2Dminor,hooking%20or%20unhooking%20Emacs'%20hooks.
  ;; Ref: https://rubikitch.hatenadiary.org/entry/20101126/keymap
  :doc "over-riding minor mode for org-mode"
  :preface
  (define-minor-mode overriding-minor-mode
    "Force to bind keymaps."
    :init-value nil
    :lighter " oride"
    ;; org-modeで使いたいバインドがあれば適宜追加
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map (kbd "C-'") 'other-window)
              (define-key map (kbd "C-\"") 'prev-window)
              (define-key map (kbd "<C-tab>") 'next-buffer)
              (define-key map (kbd "C-c <C-tab>") 'previous-buffer)
              (define-key map (kbd "C-c r") 'window-resizer)
              map))
  :config
  ;; overriding-minor-modeのキーバインド更新時に、以下のmakunboundの行を
  ;; 1回読み込みキーマップを消去する（こうする必要があるらしい）。
  ;; (makunbound 'overriding-minor-mode-map)
  (add-hook 'org-mode-hook 'overriding-minor-mode))
  (leaf diary
    :custom
    `(;; Dropboxのdiaryへのパス(起点)
      ;; Ubuntu ;"~/diary/"
      ;; (*path-to-diary* . ,(expand-file-name "~/Dropbox/diary-shared/"))
      ;; WSL2 ;"~/diary/" with a symbolic link "windows-home"
      ;; (*path-to-diary* . ,(expand-file-name "~/windows-home/Dropbox/diary-shared/"))
      ;; WSL2 Local ; Dropbox上だと遅いのでLocalに変更
      ;; バックアップ先はOneDriveに変更
      (*path-to-diary* . ,(expand-file-name "~/diary/")))
    :config
    ;; メモとか記録をする補助コマンド
    (defun open-diary (diary-type)
      "Open diary file selected by DIARY-TYPE."
      (interactive "sselect diary type: ")
      ;; template: ("shortcut-key" "message" "path-to-diary-file" "strings-inserted-at-making-file")
      (let* ((diary-alst
              (list (list "c" "current memo"
                          (concat *path-to-diary* "memo-org/current.org")
                          nil)
                    (list "m" "monthly memo log"
                          (concat *path-to-diary* (format-time-string "memo-org/%Y-%m.org" (current-time)))
                          nil)
                    (list "a" "daily anime log"
                          (concat *path-to-diary* (format-time-string "log_anime/%Y-%m-%d.txt" (current-time)))
                          (format-time-string "%m/%d/%Y-%w" (current-time)))))
             (current-diary (assoc diary-type diary-alst)))
        ;; if file does not exist
        (unless (file-exists-p (nth 2 current-diary))
          (shell-command-to-string
           (mapconcat #'shell-quote-argument
                      (list "touch" (nth 2 current-diary)) " "))
          ;; insert strings if 3rd element does not nil
          (when (nth 3 current-diary)
            (shell-command-to-string
             (mapconcat #'identity
                        (list (mapconcat #'shell-quote-argument
                                         (list "echo" (nth 3 current-diary)) " ")
                              ">>"
                              (mapconcat #'shell-quote-argument
                                         (list (nth 2 current-diary)) " ")) " "))))
        ;; if file is already open
        (if (position 0 (mapcar #'(lambda (lst) (search (car (last (split-string (nth 2 current-diary) "/"))) lst))
                                (mapcar #'buffer-name (buffer-list))))
            (switch-to-buffer (car (last (split-string (nth 2 current-diary) "/"))))
          (find-file (nth 2 current-diary)))
        (message (nth 1 current-diary)))))
  (leaf org-agenda
    :doc "Settings for my org-agenda."
    :when (file-exists-p *path-to-diary*)
    :init
    ;; アジェンダを確認するファイルとしてmemo-org ディレクトリを走査
    ;; (setq org-agenda-files (list (concat *path-to-diary* "memo-org")))
    (setq org-agenda-files (list (concat *path-to-diary* "memo-org/current.org")))
    :custom
    (;; org-captureの参照ファイル （月毎で分ける）
     ;; (org-default-notes-file . ,(concat *path-dropbox-diary* (format-time-string "memo-org/%Y-%m.org")))
     ;; (org-capture-templates . ,(list (list "n" "Note"  (list 'file org-default-notes-file))))
     ;; TODO states
     (org-todo-keywords . '((sequence "TODO(t)" "WAIT(w)" "REMIND(r)" "SOMEDAY(s)" "|" "DONE(d)" "CANCEL(c)")))
     ;; Tag list
     (org-tag-alist . '(("meeting" . ?m)
                        ("office" . ?o)
                        ("document" . ?d)
                        ("kitting" . ?k)
                        ("study" . ?s)
                        ("travel" . ?t))))
    :config
    (global-set-key (kbd "C-c a") 'org-agenda)
    ;; (global-set-key (kbd "C-c c") 'org-capture)
    ;; アジェンダ使用でファイルを開きっぱなしにしない
    (require 'dash)
    (defun my-org-keep-quiet (orig-fun &rest args)
      (let ((buffers-pre (-filter #'get-file-buffer (org-agenda-files))))
        (apply orig-fun args)
        (let* ((buffers-post (-filter #'get-file-buffer (org-agenda-files)))
               (buffers-new  (-difference buffers-post buffers-pre)))
          (mapcar (lambda (file) (kill-buffer (get-file-buffer file))) buffers-new))))
    (advice-add 'org-agenda-list :around #'my-org-keep-quiet)
    (advice-add 'org-todo-list :around #'my-org-keep-quiet)
    (advice-add 'org-search-view :around #'my-org-keep-quiet)
    (advice-add 'org-tags-view   :around #'my-org-keep-quiet)
    ;; アジェンダ表示で下線を用いる
    (add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)))))

(leaf clwc
  :doc "Display the number of lines, words and characters in the region on the mode line."
  :preface
  (defun count-lines-words-chars ()
    "Count lines, words and chars in the region."
    (if mark-active
        (format "[l:%d w:%d c:%d]"
                (count-lines (region-beginning) (region-end))
                (how-many "\\S-+" (region-beginning) (region-end))
                (- (region-end) (region-beginning))) ""))
  :config
  (let ((ml-elm '(:eval (count-lines-words-chars))))
    (unless (find ml-elm mode-line-format :test 'equal)
      (setq-default mode-line-format (cons ml-elm mode-line-format)))))

;;(leaf imaxima
;;  :doc "Settings for imaxima"
;;  ;; "sudo apt install maxima maxima-emacs"で/usr/share/emacs/site-lisp/maxima/に
;;  ;; インストールされる諸々の設定ファイルの中で、imaxima.elとimath.elとを以下のWebページから
;;  ;; インストールできるものに置き換えて、mylatex.ltx.elを追加する。
;;  ;; https://bugs.launchpad.net/ubuntu/+source/maxima/+bug/1877185
;;  ;; apt以外で入れたTeX Live 2020とのバージョンのズレによるバグらしい。
;;  ;; TeX Live 2021とのバージョンのズレにも対応できた (2022/02/05)。
;;  ;; ファイルは"~/.emacs.d/my-archive/for-imaxima/"に保存。
;;  :preface
;;  (add-to-list 'exec-path "/usr/local/texlive/2021/bin/x86_64-linux/")
;;  :custom
;;  ((imaxima-fnt-size . "LARGE")
;;   (imaxima-use-maxima-mode-flag . t)))

;; (leaf pdf-tools :ensure t
;;   :preface
;;   ;; initial setup
;;   (pdf-tools-install)
;;   :config
;;   ;; mode
;;   (add-to-list 'auto-mode-alist (cons "\\.pdf$" 'pdf-view-mode))
;;   ;; isearch-forward
;;   (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
;;   ;; open pdfs scaled to fit page
;;   (setq-default pdf-view-display-size 'fit-width)
;;   ;; automatically annotate highlights
;;   ;; (setq pdf-annot-activate-created-annotations t)
;;   ;; more fine-grained zooming
;;   (setq pdf-view-resize-factor 1.1))

(provide 'init)

;;; init.el ends here
