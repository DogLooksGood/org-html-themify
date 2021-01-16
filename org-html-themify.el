;;; org-html-themify.el --- Themify org-mode export with Emacs color theme
;;; -*- lexical-binding: t -*-

;; Author: Shi Tianshu
;; Keywords: org-mode
;; Package-Requires: ((emacs "27.1") (htmlize "1.5.6") (dash "2.17.0") (hexrgb "0"))
;; Version: 1.0.0
;; URL: https://www.github.com/DogLooksGood/org-html-themify
;;
;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; 1. Specify a light and a dark theme.
;;
;; (setq org-html-themify-themes '((dark . solarized-dark) (light . solarized-light)))
;;
;; 2. Enable org-html-themify-themes in org-mode.
;;
;; (add-hook 'org-mode-hook #'org-html-themify-mode)
;;
;; That's all, now you can export HTML.

;;; Code:

(require 'hexrgb)
(require 'htmlize)
(require 'dash)

(defvar org-html-themify-themes
  '((dark . joker)
    (light . leuven))
  "Themes used to generate inline stylesheet.")

(defvar org-html-themify--current-theme nil)

(defvar org-html-themify--backup-htmlize-face-overrides nil)

(defvar org-html-themify-css-path
  (expand-file-name
   "org-html-themify.css"
   (file-name-directory (or load-file-name (buffer-file-name)))))

(defvar org-html-themify-js-path
  (expand-file-name
   "org-html-themify.js"
   (file-name-directory (or load-file-name (buffer-file-name)))))

(defun org-html-themify--parse-clause (clause)
  (-let* (((th f a k) (split-string clause ":"))
          (fs (intern f))
          (as (intern (concat ":" a)))
          (req-theme (alist-get (intern th) org-html-themify-themes))
          (_ (unless (equal req-theme org-html-themify--current-theme)
               (when org-html-themify--current-theme (disable-theme org-html-themify--current-theme))
               (load-theme req-theme t)
               (setq org-html-themify--current-theme req-theme))))
    (let ((v (face-attribute fs as)))
      (unless (equal v 'unspecified)
        (if k
            (plist-get v (intern (concat ":" k)))
          v)))))

(defun org-html-themify--get-interpolate-value (s)
  (let* ((clauses (-> s
                      (string-trim-left "#{")
                      (string-trim-right "}")
                      (split-string "|")))
         (vals (-keep #'org-html-themify--parse-clause clauses))
         (val (car vals)))
    (cond
     ((null val) "initial")
     ((hexrgb-rgb-hex-string-p val) val)
     ((hexrgb-color-name-to-hex val 2)))))

(defun org-html-themify--interpolate ()
  (let ((inhibit-redisplay t)
        (orig-themes custom-enabled-themes))
    (mapc (lambda (th) (disable-theme th)) orig-themes)
    (goto-char (point-min))
    (while (re-search-forward "#{.+?}" nil t)
      (-let* ((beg (match-beginning 0))
              (end (match-end 0))
              (s (buffer-substring-no-properties beg end))
              (v (org-html-themify--get-interpolate-value s)))
        (delete-region beg end)
        (insert v)))
    (disable-theme org-html-themify--current-theme)
    (mapc (lambda (th) (load-theme th t)) orig-themes)))

(defun org-html-themify--setup-inlines (exporter)
  "Insert custom inline css"
  (when (eq exporter 'html)
    (setq org-html-preamble
          (concat
           "<div id=\"toggle-theme\">dark theme</div>"
           "<div id=\"toggle-toc\">&#9776;</div>"))
    (setq org-html-head-include-default-style nil)
    (setq org-html-head (concat
                         "<style type=\"text/css\">\n"
                         "<!--/*--><![CDATA[/*><!--*/\n"
                         (with-temp-buffer
                           (insert-file-contents org-html-themify-css-path)
                           (org-html-themify--interpolate)
                           (buffer-string))
                         "/*]]>*/-->\n"
                         "</style>\n"))
    (setq org-html-postamble
          (concat
           "<script type=\"text/javascript\">\n"
           "<!--/*--><![CDATA[/*><!--*/\n"
           (with-temp-buffer
             (insert-file-contents org-html-themify-js-path)
             (buffer-string))
           "/*]]>*/-->\n"
           "</script>"))))

(defun org-html-themify--init ()
  (add-hook 'org-export-before-processing-hook 'org-html-themify--setup-inlines)
  (setq org-html-themify--backup-htmlize-face-overrides htmlize-face-overrides)
  (setq htmlize-face-overrides
   '(font-lock-keyword-face (:foreground "var(--clr-keyword)" :background "var(--bg-keyword)")
     font-lock-constant-face (:foreground "var(--clr-constant)" :background "var(--bg-constant)")
     font-lock-comment-face (:foreground "var(--clr-comment)" :background "var(--bg-comment)")
     font-lock-comment-delimiter-face (:foreground "var(--clr-comment-delimiter)" :background "var(--bg-comment-delimiter)")
     font-lock-function-name-face (:foreground "var(--function-clr-name)" :background "var(--function-bg-name)")
     font-lock-variable-name-face (:foreground "var(--clr-variable)" :background "var(--bg-variable)")
     font-lock-preprocessor-face (:foreground "var(--clr-preprocessor)" :background "var(--bg-preprocessor)")
     font-lock-doc-face (:foreground "var(--clr-doc)" :background "var(--bg-doc)")
     font-lock-builtin-face (:foreground "var(--clr-builtin)" :background "var(--bg-builtin)")
     font-lock-string-face (:foreground "var(--clr-string)" :background "var(--bg-string)"))))

(defun org-html-themify--uninit ()
  (remove-hook 'org-export-before-processing-hook 'org-html-themify--setup-inlines)
  (setq htmlize-face-overrides org-html-themify--backup-htmlize-face-overrides))

(define-minor-mode org-html-themify-mode
  "Themify org-mode HTML export with Emacs color theme."
  nil
  nil
  nil
  (if org-html-themify-mode
      (org-html-themify--init)
    (org-html-themify--uninit)))

(provide 'org-html-themify)
;;; org-html-themify ends here.
