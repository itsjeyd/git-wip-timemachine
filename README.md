## git-wip-timemachine [![License: GPL](https://img.shields.io/badge/license-GPL-blue.svg)](http://opensource.org/licenses/GPL-3.0) [![MELPA](http://melpa.org/packages/git-wip-timemachine-badge.svg)](http://melpa.org/#/git-wip-timemachine) [![MELPA Stable](http://stable.melpa.org/packages/git-wip-timemachine-badge.svg)](http://stable.melpa.org/#/git-wip-timemachine)

`git-wip-timemachine` is a modified version of
[`git-timemachine`](https://github.com/pidu/git-timemachine) by Peter
Stiernström that allows you to browse
[`git-wip`](https://github.com/itsjeyd/git-wip) versions of files from
Emacs.

### Installation

`git-wip-timemachine` is on [MELPA](http://melpa.org/). To
start using it, follow these steps:

1. If you haven't already, set up
   [`git-wip`](https://github.com/itsjeyd/git-wip):

   - Clone the `git-wip` package to your `$HOME` directory:

             $ cd
             $ git clone https://github.com/itsjeyd/git-wip

     If you decide to clone to a different directory and that
     directory is *not* part of your `exec-path` in Emacs, you'll need
     to add the following code to your init-file (to make sure Emacs
     can find the `git-wip` script):

            (add-to-list 'exec-path "/path/to/git-wip")

   - Add the following code to your init-file:

            (load "/path/to/git-wip/emacs/git-wip.el")

     From now on, every time you save a file that is part of a `git`
     repository, Emacs will automatically create a WIP commit by
     calling out to `git-wip` for you.

2. Install `git-wip-timemachine` via:

   <kbd>M-x</kbd> `package-install` <kbd>RET</kbd> `git-wip-timemachine` <kbd>RET</kbd>

### Usage

Issue <kbd>M-x</kbd> `git-wip-timemachine` to browse through WIP
versions of a file.

Use the following keys to navigate WIP versions of the file:

- <kbd>.</kbd> Visit current (latest) WIP version.
- <kbd>></kbd> Visit current (latest) WIP version.
- <kbd><</kbd> Visit oldest WIP version (equivalent to merge base of current branch and associated WIP branch *if* merge base introduces changes to current file).
- <kbd>p</kbd> Visit previous WIP version.
- <kbd>n</kbd> Visit next WIP version.
- <kbd>g</kbd> Visit nth WIP version.
- <kbd>w</kbd> Copy the abbreviated hash of the current WIP version.
- <kbd>W</kbd> Copy the full hash of the current WIP version.
- <kbd>q</kbd> Exit the time machine.

If you want, you can of course bind `git-wip-timemachine` to a key
sequence of your choice.

Finally, there's also `git-wip-timemachine-toggle` which does exactly
what its name suggests: If the timemachine is on, calling this command
will turn it off (and vice versa).

### Interactions with other modes

[`lispy-mode`](https://github.com/abo-abo/lispy) interferes with the
default bindings of `git-wip-timemachine`. If it is on when you start
the timemachine, it will be turned off automatically (and become
active again when you exit the timemachine).

### Bonus: Magit integration

If you use [`magit`](https://github.com/magit/magit), you might be
interested in having your WIP commits listed in the `*magit-log*`
buffer. Follow these steps to do this interactively:

1. Hit <kbd>l</kbd> to bring up the menu for logging.

2. Enter `-al` to enable the `--all` switch.

3. Hit <kbd>l</kbd> (or <kbd>L</kbd>, if you want to see stats as
   well).

If you want to enable the `--all` switch by default, you can add the
following code to your init-file:

    (defun magit-log-all ()
      (interactive)
      (magit-key-mode-popup-logging)
      (magit-key-mode-toggle-option 'logging "--all"))

    (define-key magit-mode-map (kbd "l") 'magit-log-all)

Note that while `git-wip-timemachine` only considers WIP commits that
introduce changes to the file it was called from, `magit` will show
*all* WIP commits by default (irrespective of the file(s) they touch).
