## git-wip-timemachine

`git-wip-timemachine` is a modified version of
[`git-timemachine`](https://github.com/pidu/git-timemachine) by Peter
Stiernström that allows you to browse
[`git-wip`](https://github.com/itsjeyd/git-wip) versions of files from
Emacs.

### Installation

`git-wip-timemachine` is not on [MELPA](http://melpa.org/) (yet). To
start using it, follow these steps:

1. Set up [`git-wip`](https://github.com/itsjeyd/git-wip):

   - Clone `git-wip` to your `$HOME` directory:

            $ cd
            $ git clone https://github.com/itsjeyd/git-wip

     You can also clone `git-wip` to a different directory. Note that
     if this directory is not part of your `exec-path` in Emacs,
     you'll need to update the first line in
     `/path/to/git-wip/emacs/git-wip.el` accordingly.

   - Add the following code to your init-file:

            (load "/path/to/git-wip/emacs/git-wip.el")

     Next time you save a file that is part of a `git` repository,
     Emacs will automatically create a WIP commit by calling out to
     `git-wip` for you.

2. Clone this repo:

        git clone https://github.com/itsjeyd/git-wip-timemachine.git

3. Add the following to your init-file:

        (add-to-list 'load-path "~/path/to/git-wip-timemachine/")
        (require 'git-wip-timemachine)

### Usage

If you've used `git-timemachine` before you can stop reading now --
`git-wip-timemachine` provides the same set of commands and default
key bindings.

Issue <kbd>M-x</kbd> `git-wip-timemachine` to browse through WIP
versions of a file.

Use the following keys to navigate WIP versions of the file:

- <kbd>p</kbd> Visit previous WIP version.
- <kbd>n</kbd> Visit next WIP version.
- <kbd>w</kbd> Copy the abbreviated hash of the current WIP version.
- <kbd>W</kbd> Copy the full hash of the current WIP version.
- <kbd>q</kbd> Exit the time machine.

If you want, you can of course bind `git-wip-timemachine` to a key
sequence of your choice.

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
