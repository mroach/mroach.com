# mroach.com

This is a static website generated using [Hugo].

## Up and running

### Clone

The theme is included in the repo as a git submodule, so clone the repo with the `--recurse-submodules` argument or after cloning, run:

```shell
git submoule update --init --recursive
```

### Install Hugo

To preview changes locally, install Hugo.

#### macOS

```shell
brew install hugo
```

#### Debian

Grab the right .deb file from the [latest release][hugo latest release] and install it

```shell
sudo dpkg -i hugo*.deb
```

[hugo]: https://gohugo.io/
[hugo latest release]: https://github.com/gohugoio/hugo/releases/latest

### Run Hugo

```shell
hugo serve
```

Now you visiting http://localhost:1313 should work.
