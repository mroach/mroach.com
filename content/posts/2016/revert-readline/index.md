---
date: 2016-09-29T00:00:00Z
title: Reverting to Readline 6.3.8 to unbreak the Rails console
categories:
  - tech
tags:
  - ruby
  - macos
  - homebrew
---

When running a `brew upgrade`, it upgraded `readline` to version 7.0. This
broke the Rails console.

<!--more-->

Here's how that looked:

```shell
bundle exec rails c

Running via Spring preloader in process 69075
/Users/mroach/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/activesupport-5.0.0.1/lib/active_support/dependencies.rb:293:in `require':
  dlopen(/Users/mroach/.rbenv/versions/2.3.1/lib/ruby/2.3.0/x86_64-darwin15/readline.bundle, 9):
  Library not loaded: /usr/local/opt/readline/lib/libreadline.6.dylib (LoadError)
```

Here's how I reverted to readline 6.3.8 to fix this:

```bash
# Uninstall this incompatible version
brew uninstall readline

# Go to the local clone of homebrew-core
cd $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core

# Move to the homebrew-core revision that had 6.3.8
git checkout 35fed817726f61a9d40c8420582f6fde59eb5f14

# Re-install readline
brew reinstall readline

# Switch back to HEAD
git checkout master

# Pin readline so this can't happen again
brew pin readline
```
