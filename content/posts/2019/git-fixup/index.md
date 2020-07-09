---
date: 2019-02-12T00:00:00Z
title: "Cleaning-up your commit history with git --fixup"
categories:
  - Tech
  - Guide
tags:
  - Git
  - Development
aliases:
  - /2019/02/12/git-fixup/
---

I like to keep my git commit history clean and concise. If each commit is a clean package of atomic changes, a larger pull request is easier to review commit by commit. Conversely, if you have a history littered with fixes and changes, reviewing each commit doesn't work.

`git rebase -i` is a great way to re-order commits, drop commits, or merge commits together with `squash` or `fixup`. The only difference is that `fixup` discards the commit message whereas `squash` appends it.

Consider a workflow where you've added a feature to your app and commit this change.

```shell
git add app/
git commit -m "Add feature"
```

Now let's say you notice you forgot your new test files to this commit so you `add` them. At this point you can easily do a `git commit --amend --no-edit` which will amend the previous commit and use the original commit message. Easy!

But what happens if you've made a commit since then that has nothing to do with this feature? You could just make a separate commit:

```shell
git add test/
git commit -m "oops, forgot the test files for the new feature"
```

A better way is to use the `--fixup` flag.

First, use `git log` to get the hash of the commit you want to amend. Then commit your amendment like so:

```shell
git add test/
git commit --fixup=hash_of_commit_to_amend
```

This creates a normal commit with a special message. In this case it would be `!fixup Add feature`. Now, run `git rebase -i --autosquash` and you'll see the magic.

```
pick f0f6a56 Add feature
fixup 7897d4d fixup! Add feature
pick 03b9a80 Fix unrelated bug
 ```

Git recognises the `!fixup` commit and places it after the commit to amend and automatically sets it as a `fixup`. Now when you quit the editor, history will be re-written.

By default when you use `git rebase -i --autosquash` it only shows commits that have happened since your last push. So if you use `--fixup` on a commit already pushed to the remote, it won't do anything. You can work around this by rebasing farther into the past, but that will then require a force push and all the usual caveats there. If your branch history needs that much re-working, you might just want to create a new one.
