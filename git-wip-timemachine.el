;;; git-wip-timemachine.el --- Walk through git-wip revisions of a file

;; Copyright (C) 2014-2015 Tim Krones

;; Author: Tim Krones
;; Verson: 1.0
;; URL: https://github.com/itsjeyd/git-wip-timemachine
;; Keywords: git

;;; This file is not part of GNU Emacs

;;; License

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Use git-wip-timemachine to browse git-wip versions of a file with
;; p (previous) and n (next).

;;; Credits:

;; git-wip-timemachine is a modified version of git-timemachine
;; (https://github.com/pidu/git-timemachine) by Peter Stiernström, so
;; all credit for the original idea goes to him.

;;; Code:

(require 'cl-lib)
(require 's)

(defvar git-wip-timemachine-branch nil)
(defvar git-wip-timemachine-directory nil)
(defvar git-wip-timemachine-file nil)
(defvar git-wip-timemachine-merge-base nil)
(defvar git-wip-timemachine-revision nil)

(make-variable-buffer-local 'git-wip-timemachine-branch)
(make-variable-buffer-local 'git-wip-timemachine-directory)
(make-variable-buffer-local 'git-wip-timemachine-file)
(make-variable-buffer-local 'git-wip-timemachine-merge-base)
(make-variable-buffer-local 'git-wip-timemachine-revision)

;; Command (excluding hash of last commit of wip "parent branch"):
;; git log wip/<branch>...$(git merge-base wip/<branch> <branch>) --pretty=format:%h <file>

;; Command (including hash of last commit of wip "parent branch"):
;; git log wip/<branch> <branch> ^$(git merge-base wip/<branch> <branch>)~1 --pretty=format:%h <file>

;; Programmatically determine current branch:
;; git symbolic-ref --short -q HEAD
;; Source: http://git-blame.blogspot.de/2013/06/checking-current-branch-programatically.html

(defun git-wip-timemachine--revisions ()
 "List git-wip revisions of current buffer's file."
 (split-string
  (shell-command-to-string
   (format "cd %s && git log wip/%s %s ^%s~1 --pretty=format:%s %s"
    (shell-quote-argument git-wip-timemachine-directory)
    (shell-quote-argument git-wip-timemachine-branch)
    (shell-quote-argument git-wip-timemachine-branch)
    (shell-quote-argument git-wip-timemachine-merge-base)
    (shell-quote-argument "%h")
    (shell-quote-argument git-wip-timemachine-file)))))

(defun git-wip-timemachine-show-current-revision ()
 "Show last (current) revision of file."
 (interactive)
 (git-wip-timemachine-show-revision (car (git-wip-timemachine--revisions))))

(defun git-wip-timemachine-show-previous-revision ()
 "Show previous revision of file."
 (interactive)
 (git-wip-timemachine-show-revision
  (cadr (member git-wip-timemachine-revision
                (git-wip-timemachine--revisions)))))

(defun git-wip-timemachine-show-next-revision ()
 "Show next revision of file."
 (interactive)
 (git-wip-timemachine-show-revision
  (cadr (member git-wip-timemachine-revision
                (reverse (git-wip-timemachine--revisions))))))

(defun git-wip-timemachine-show-revision (revision)
 "Show a REVISION (commit hash) of the current file."
 (when revision
  (let ((current-position (point)))
   (setq buffer-read-only nil)
   (erase-buffer)
   (insert
    (shell-command-to-string
     (format "cd %s && git show %s:%s"
      (shell-quote-argument git-wip-timemachine-directory)
      (shell-quote-argument revision)
      (shell-quote-argument git-wip-timemachine-file))))
   (setq buffer-read-only t)
   (set-buffer-modified-p nil)
   (let* ((revisions (git-wip-timemachine--revisions))
          (n-of-m (format "(%d/%d)"
                          (- (length revisions)
                             (cl-position revision revisions :test 'equal))
                          (length revisions))))
    (setq mode-line-format
          (list "Commit: " revision " -- %b -- " n-of-m " -- [%p]")))
   (setq git-wip-timemachine-revision revision)
   (goto-char current-position))))

(defun git-wip-timemachine-quit ()
 "Exit the timemachine."
 (interactive)
 (kill-buffer))

(defun git-wip-timemachine-kill-revision ()
 "Kill the current revision's commit hash."
 (interactive)
 (let ((this-revision git-wip-timemachine-revision))
  (with-temp-buffer
   (insert this-revision)
   (message (buffer-string))
   (kill-region (point-min) (point-max)))))

(define-minor-mode git-wip-timemachine-mode
 "Git WIP Timemachine, feel the wings of history."
 :init-value nil
 :lighter " WIP Timemachine"
 :keymap
 '(("p" . git-wip-timemachine-show-previous-revision)
   ("n" . git-wip-timemachine-show-next-revision)
   ("q" . git-wip-timemachine-quit)
   ("w" . git-wip-timemachine-kill-revision))
 :group 'git-wip-timemachine)

;;;###autoload
(defun git-wip-timemachine ()
 "Enable git-wip timemachine for file of current buffer."
 (interactive)
 (let* ((git-directory (concat (s-trim-right
                                (shell-command-to-string
                                 "git rev-parse --show-toplevel")) "/"))
        (current-branch (s-trim-right
                         (shell-command-to-string
                          "git symbolic-ref --short -q HEAD")))
        (merge-base (s-trim-right
                     (shell-command-to-string
                      (format "git merge-base wip/%s %s"
                              current-branch current-branch))))
        (relative-file (s-chop-prefix git-directory (buffer-file-name)))
        (timemachine-buffer (format "WIP timemachine:%s" (buffer-name))))
  (with-current-buffer (get-buffer-create timemachine-buffer)
   (setq buffer-file-name relative-file)
   (set-auto-mode)
   (git-wip-timemachine-mode)
   (setq git-wip-timemachine-directory git-directory
         git-wip-timemachine-file relative-file
         git-wip-timemachine-revision nil
         git-wip-timemachine-branch current-branch
         git-wip-timemachine-merge-base merge-base)
   (git-wip-timemachine-show-current-revision)
   (switch-to-buffer timemachine-buffer))))

(provide 'git-wip-timemachine)

;;; git-wip-timemachine.el ends here
