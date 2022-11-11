;;; ob-scad.el --- Babel Functions for OpenSCAD -*- lexical-binding: t -*-

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Org Babel support for OpenSCAD

;;; Code:

(require 'ob)
(require 'scad-mode)

(defvar org-babel-default-header-args:scad
  '((:results . "file")
    (:exports . "results"))
  "Default arguments for evaluating a scad source block.")

(defvar org-babel-header-args:scad
  '((colorscheme . :any)
    (imgsize . :any)
    (camera . :any)
    (views . :any))
  "Scad specific header args.")

(defun org-babel-execute:scad (body params)
  "Evaluate BODY with `scad-command' given PARAMS."
  (let* ((outfile (or (alist-get :file params)
                      (error "Scad code block requires :file header argument")))
         (infile (org-babel-temp-file "scad-")))
    (message "%S" params)
    (with-temp-file infile (insert body))
    (apply #'call-process scad-command nil 0 nil
           (delq nil
                 (list "-o" outfile
                       "--preview"
                       "--viewall"
                       (format "--colorscheme=%s"
                               (alist-get :colorscheme params scad-preview-colorscheme))
                       (format "--views=%s" (or (alist-get :views params)
                                                (mapconcat #'identity scad-preview-view ",")))
                       (when-let (camera (alist-get :camera params))
                         (format "--camera=%s" camera))
                       (when-let (imgsize (alist-get :imgsize params))
                         (format "--imgsize=%s" imgsize))
                       infile)))
    nil))

(provide 'ob-scad)
;;; ob-scad.el ends here
