# About

`git-wip` is a script that will manage Work In Progress (or WIP)
branches. WIP branches are mostly throw-away but they identify points
of development between commits. **The intent is to tie this script
into your editor** so that each time you save your file, the `git-wip`
script captures that state in `git`. `git-wip` also helps you return
back to a previous state of development.

Latest `git-wip` can be obtained from
[github.com](http://github.com/bartman/git-wip). `git-wip` was written
by [Bart Trojanowski](mailto:bart@jukie.net).

# WIP branches

WIP branches are named after the branch that is being worked on, but
are prefixed with `wip/`. For example, if you are working on a branch
named `feature`, the `git-wip` script will only manipulate the
`wip/feature` branch.

When you run `git-wip` for the first time, it will capture all changes
to tracked files and all untracked (but not ignored) files, create a
commit, and make a new `wip/topic` branch point to it:

    --- * --- * --- *          <-- topic
                     \
                      *        <-- wip/topic

The next invocation of `git-wip` after a commit is made will continue
to evolve the work from the last `wip/topic` point:

    --- * --- * --- *          <-- topic
                     \
                      *
                       \
                        *      <-- wip/topic

When `git-wip` is invoked after a commit is made, the state of the
`wip/topic` branch will be reset back to your `topic` branch and the
new changes to the working tree will be captured in a new commit:

    --- * --- * --- * --- *    <-- topic
                     \     \
                      *     *  <-- wip/topic
                       \
                        *

While the old `wip/topic` work is no longer accessible directly, it
can always be recovered from `git-reflog`. In the example above you
could use `wip/topic@{1}` to access the dangling references.

# The `git-wip` command

The `git-wip` command can be invoked in several different ways.

* `git wip`

  In this mode, `git-wip` will create a new commit on the `wip/topic`
  branch (creating it if needed) as described above.

* `git wip save "description"`

  Similar to `git wip`, but allows for a custom commit message.

* `git wip log`

  Show the list of the work that leads up to the last WIP commit. This
  is similar to invoking:

  `git log --stat wip/$branch...$(git merge-base wip/$branch $branch)`

# Editor hooking

To use `git-wip` effectively, you should tie it into your editor so
you don't have to remember to run `git-wip` manually.

## Vim

To add `git-wip` support to Vim you can install the provided Vim
plugin. There are a few ways to do this.

**(1)** If you're using [Vundle](https://github.com/gmarik/Vundle.vim), you
just need to include the following line in your `.vimrc`:

    Bundle 'bartman/git-wip', {'rtp': 'vim/'}

**(2)** You can also copy the `git-wip.vim` into your Vim runtime:

    cp vim/plugin/git-wip ~/.vim/plugin/git-wip

**(3)** Alternatively, you can add the following to your `.vimrc`;
doing so will cause `git-wip` to be invoked after every `:w`
operation:

    augroup git-wip
      autocmd!
      autocmd BufWritePost * :silent !cd "`dirname "%"`" && git wip save "WIP from vim" --editor -- "`basename "%"`"
    augroup END

The `--editor` option puts `git-wip` into a special mode that will
make it more quiet and not report errors if there were no changes made
to the file.

## Emacs

To add `git-wip` support to Emacs add the following to your `.emacs`;
doing so will cause `git-wip` to be invoked after every `save-buffer`
operation:

    (load "/{path_to_git-wip}/emacs/git-wip.el")

Alternatively, you can copy the content of `git-wip.el` to your
`.emacs`.

### Bonus: Magit integration

If you use [`magit`](https://github.com/magit/magit), you might be
interested in having your WIP commits listed in the `*magit-log*`
buffer. Follow these steps to do this interactively:

1. Hit <kbd>l</kbd> to bring up the menu for logging.

2. Enter `-al` to enable the `--all` switch.

3. Hit <kbd>l</kbd> (or <kbd>L</kbd>, if you want to see stats as
   well).

If you want to enable the `--all` switch by default, you can add the
following code to your `.emacs`:

    (defun magit-log-all ()
      (interactive)
      (magit-key-mode-popup-logging)
      (magit-key-mode-toggle-option 'logging "--all"))

    (define-key magit-mode-map (kbd "l") 'magit-log-all)

### Bonus: Walking through WIP versions of files

1. Install
   [`git-wip-timemachine`](https://github.com/pidu/git-timemachine)
   from MELPA via:

   <kbd>M-x</kbd> `package-install` <kbd>RET</kbd> `git-wip-timemachine` <kbd>RET</kbd>

2. From any file that has some WIP commits associated with it:

   <kbd>M-x</kbd> `git-wip-timemachine` <kbd>RET</kbd>

3. Navigate between WIP versions of the file using <kbd>n</kbd> and
   <kbd>p</kbd>. To quit the time machine, press <kbd>q</kbd>.

For more information, see the `git-wip-timemachine`
[README](https://github.com/itsjeyd/git-wip-timemachine/blob/master/README.md).

## Sublime

A Sublime plugin was contributed as well. You can find it in the
`sublime` directory.

# Recovery

Should you discover that you made some really bad changes to your code
from which you want to recover, here is what to do:

First we need to find the commit we are interested in. If it's the
most recent one, it can be referenced with `wip/master` (assuming your
branch is `master`). Otherwise you may need to find the commit you
want using:

    git reflog show wip/master

I personally prefer to inspect the reflog with `git log -g`, and
sometimes with `-p` also:

    git log -g -p wip/master

Once you've picked a commit, you need to `checkout` the files. Note
that we are not switching the commit that your branch points to (i.e.,
`HEAD` will continue to reference the last real commit on the branch).
We are just checking out the files:

    git checkout ref -- .

`ref` could be a SHA1 or `wip/master`. If you only want to recover one
file, use its path instead of the *dot*.

The changes will be staged in the index and checked out into the
working tree, to review what the differences are between the last
commit, use:

    git diff --cached

If you want, you can unstage all or some with `git reset`, optionally
specifying a filename to unstage. You can then stage them again using
`git add` or `git add -p`. Finally, when you're happy with the
changes, commit them.

<!-- vim: set ft=markdown -->
