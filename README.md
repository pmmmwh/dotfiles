# `pmmmwh@dotfiles`

## Getting Started

> ⚠️ **WARNING** ⚠️ - Proceed at your own risk.
>
> The setup here have been tweaked to cater my personal workflow.
> They don't suit everyone, so please review the code to make sure the dotfiles fit your setup.

First, install [`mise`](https://mise.jdx.dev), which will drive everything:

```sh
curl https://mise.run | sh
```

Then, run `bootstrap`:

```sh
mise bootstrap --from https://github.com/pmmmwh/dotfiles.git --yes
```

**Personal Stuff**

On my personal machines, `-E personal` is added to pull in extra apps and tools:

```sh
mise -E personal bootstrap --from https://github.com/pmmmwh/dotfiles.git --yes
```

This will install system packages, clone Zsh plugins, link the dotfiles,
write macOS defaults and install tool chains.

**macOS Settings**

Some macOS settings cannot be expressed in mise, and they are applied as a separate step:

```sh
mise run macos-settings
```

## Operations

### Structure

| Where                              | What                                                          |
| ---------------------------------- | ------------------------------------------------------------- |
| `mise.toml`                        | Machine setup - dotfiles, plugin repos, packages, defaults    |
| `mise.personal.toml`               | Same as above, for personal machines                          |
| `config/mise/config.toml`          | Tools available everywhere, symlinked to `~/.config/mise`     |
| `config/mise/config.personal.toml` | Sams as above, for personal machines                          |
| `@macos/Brewfile`                  | Casks, App Store apps, and formulae from taps mise can't pour |
| `@macos/settings.zsh`              | Privileged, host-scoped and collection-valued macOS settings  |

Anything under `@` is operating-system specific;
anything under `_` is not linked anywhere.

### Inspecting

```sh
mise bootstrap status
```

This will report every managed part.

If you only care about one, you can use the narrower commands:

```sh
mise bootstrap dotfiles status
mise bootstrap packages status
mise bootstrap macos defaults status
```

To exit with non-zero when something is out of sync, add `--missing` to the commands.

### Customisation

Any `.zsh` file inside [`.zshcustom`](./zsh/.zshcustom) is sourced at startup.
If you have machine-local values that should not be committed,
you can utilise unmanaged Zsh files in the directory (e.g. `~/.zshcustom/extras.zsh`).

### Reverting

```sh
mise bootstrap dotfiles unapply
```

This will remove all symlinks mise created,
but not revert any installed packages and tools, or any applied macOS defaults.

If you need to uninstall packages:

```sh
brew uninstall
```

## Acknowledgements

- [Github does dotfiles](https://dotfiles.github.io)
- [Dotfiles](https://github.com/mathiasbynens/dotfiles) by [@mathiasbynens](https://github.com/mathiasbynens),
  which is an amazing starting point for custom dotfiles
  (also contains the amazing `~/.macos` script!)
- [Dotfiles](https://github.com/driesvints/dotfiles) by [@driesvints](https://github.com/driesvints),
  which introduced me to tools like `mackup` and `mas` to manage apps and preferences
- [Dock.sh](https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8) by [@kamui545](https://github.com/kamui545),
  which is used here to programmatically setup the macOS Dock
