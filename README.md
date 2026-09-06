# `pmmmwh@dotfiles`

## Getting Started

> ⚠️ **WARNING** ⚠️ - Proceed at your own risk.
>
> The setup here have been tweaked to cater my personal workflow.
> They don't suit everyone, so please review the code to make sure the dotfiles fit your setup.

Everything is driven by [`mise`](https://mise.jdx.dev), which is the only thing
that has to be installed by hand:

```sh
curl https://mise.run | sh
```

From there, one command sets up the machine:

```sh
mise bootstrap --from https://github.com/pmmmwh/dotfiles.git --yes
```

On a personal machine, add `-E personal` to also pull in the apps and tools
that only belong there:

```sh
mise -E personal bootstrap --from https://github.com/pmmmwh/dotfiles.git --yes
```

That installs system packages, clones the Zsh plugins, links the dotfiles,
writes the macOS defaults and installs the tools. macOS settings that mise
cannot express are a separate, deliberate step:

```sh
mise run macos-settings
```

## Operations

### Structure

| Where                              | What                                                        |
| ---------------------------------- | ----------------------------------------------------------- |
| `mise.toml`                        | Machine setup - dotfiles, plugin repos, packages, defaults  |
| `mise.personal.toml`               | The same, for personal machines only                        |
| `config/mise/config.toml`          | Tools available everywhere, symlinked to `~/.config/mise`   |
| `config/mise/config.personal.toml` | Tools for personal machines                                 |
| `@macos/Brewfile`                  | Casks, App Store apps, and formulae from taps mise can't pour |
| `@macos/settings.zsh`              | Privileged, host-scoped and collection-valued macOS settings |

Anything under `@` is operating-system specific; anything under `_` is not
linked anywhere.

### Inspecting

`mise bootstrap status` reports every declarative part at once - packages,
repos, dotfiles, macOS defaults and tools. The narrower commands are useful
when you only care about one:

```sh
mise bootstrap dotfiles status
mise bootstrap packages status
mise bootstrap macos defaults status
```

Add `--missing` to any of them to exit non-zero when something is out of sync.
Nothing is ever applied implicitly - `apply` and `mise bootstrap` are the only
commands that change anything, and both take `--dry-run`.

### Customisation

Any `.zsh` file inside [`.zshcustom`](./zsh/.zshcustom) is sourced at startup.
Machine-local values that should not be committed go in
`~/.zshcustom/extras.zsh`, which mise deliberately does not manage.

### Reverting

```sh
mise bootstrap dotfiles unapply
```

This removes the symlinks mise created, leaving the sources alone. Packages,
tools and macOS defaults are not reverted - mise never deletes a default, and
removing packages is left to `brew uninstall` so it stays an explicit choice.

## Acknowledgements

- [Github does dotfiles](https://dotfiles.github.io)
- [Dotfiles](https://github.com/mathiasbynens/dotfiles) by [@mathiasbynens](https://github.com/mathiasbynens),
  which is an amazing starting point for custom dotfiles
  (also contains the amazing `~/.macos` script!)
- [Dotfiles](https://github.com/driesvints/dotfiles) by [@driesvints](https://github.com/driesvints),
  which introduced me to tools like `mackup` and `mas` to manage apps and preferences
- [Dock.sh](https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8) by [@kamui545](https://github.com/kamui545),
  which is used here to programmatically setup the macOS Dock
