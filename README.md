# `pmmmwh@dotfiles`

## Getting Started

> ⚠️ **WARNING** ⚠️ - Proceed at your own risk.
>
> The setup here have been tweaked to cater my personal workflow.
> They don't suit everyone, so please review the code to make sure the dotfiles fit your setup.

First, clone the repository with submodules. You can put it wherever you want.

```sh
git clone --recurse-submodules --remote-submodules https://github.com/pmmmwh/dotfiles.git
cd dotfiles
```

Then, set [the bootstrap script](./bootstrap) as executable and run it.
It will ensure the environment contains binaries needed for the setup (Git and GNU Stow).

```sh
chmod u+x bootstrap
bootstrap
```

The environment is now properly setup and ready to go.

### macOS

If you're using macOS, you can also setup a few extra things.

Setting some sensible macOS defaults with [`settings.zsh`](./@macos/settings.zsh).

```sh
chmod u+x @macos/settings.zsh
@macos/settings.zsh
```

Installing binaries and apps (via [`Homebrew`](https://brew.sh) and [`mas`](https://github.com/mas-cli/mas)) with [`brew.zsh`](./@macos/brew.zsh):
(The actual list is in the [`Brewfile`](./@macos/Brewfile))

```sh
chmod u+x @macos/brew.zsh
@macos/brew.zsh
```

## Operations

### Customisation

If you want to customise the setup, you can add `.zsh` files within the [`.zshcustom`](./zsh/.zshcustom) folder.
It has been set as the "custom" directory for `Oh My Zsh`, so any `.zsh` files inside will be automatically sourced.

### Reverting

If you do not like the setup and would like to revert the changes it did, you can run the teardown script.
It will remove any symlinks created by the bootstrap process.

```sh
chmod u+x teardown
teardown
```

### Updating

To update, go to your local `dotfiles` repository and run the teardown script.
Then, re-run the bootstrap script -
it will then pull in the latest changes and re-run the whole setup process.

```sh
cd dotfiles
teardown
bootstrap
```

## Structure

The project have been structured as Stow packages and named with a specific convention in mind:

- `lowercase` for anything to be symlinked to `$HOME`
- a leading `@` for anything dependent on the installation operating system
- a leading `_` for anything that should not be symlinked (i.e. not a Stow package.)

External packages are applied using Git Submodules.
Here's a list of all dependencies pulled in:

- [`Oh My Zsh`](https://github.com/ohmyzsh/ohmyzsh)
- [`evalcache`](https://github.com/mroth/evalcache)
- [`tpm`](https://github.com/tmux-plugins/tpm)
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions)
- [`zsh-lazyload`](https://github.com/qoomon/zsh-lazyload)

## Acknowledgements

- [Github does dotfiles](https://dotfiles.github.io)
- [Dotfiles](https://github.com/mathiasbynens/dotfiles) by [@mathiasbynens](https://github.com/mathiasbynens),
  which is an amazing starting point for custom dotfiles
  (also contains the amazing `~/.macos` script!)
- [Dotfiles](https://github.com/Kraymer/F-dotfiles) by [@Kraymer](https://github.com/Kraymer),
  which inspired me to use GNU Stow for dotfiles management
- [Dotfiles](https://github.com/driesvints/dotfiles) by [@driesvints](https://github.com/driesvints),
  which introduced me to tools like `mackup` and `mas` to manage apps and preferences
- [Dock.sh](https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8) by [@kamui545](https://github.com/kamui545),
  which is used here to programmatically setup the macOS Dock
