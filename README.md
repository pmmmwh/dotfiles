# `pmmmwh@dotfiles`

## Getting Started

> ⚠️ **WARNING** ⚠️ - Proceed at your own risk.
>
> The setup here have been tweaked to cater my personal workflow.
> They don't suit everyone, so please review the code to make sure the dotfiles fit your setup.

First, install [`mise`](https://mise.jdx.dev), which will then drive everything:

```sh
curl https://mise.run | sh
```

Then, run `bootstrap`, with `<checkout>` being wherever this repository should live:

```sh
mise bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
```

This will install system packages, clone Zsh plugins, link the dotfiles, write macOS defaults and install tool chains.

**Environments**

When `-E personal` or `-E work` is specified, the corresponding extras are applied:

```sh
mise -E personal bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
mise -E work bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
```

The chosen environment is recorded in `miserc.local.toml` (non-committed), so `-E` is only needed on this first run.

**macOS Settings**

Most macOS defaults are managed in mise.
There are some exceptions where sudo is required, and they are applied as a separate step:

```sh
mise run macos-settings
```

When defaults are written, sometimes a relaunch is required for them to take effect.
For those managed by mise, it will print a reminder when this is needed.
For those handled by the task, this is handled automatically on completion (restarts Dock, Finder and SystemUIServer).

## Operations

### Structure

This repository is mise's global config directory, so files are laid out for how mise reads them:

| Where                    | What                                                         |
| ------------------------ | ------------------------------------------------------------ |
| `config.toml`            | Tools, settings, dotfiles, vars, plugin repos, login shell   |
| `conf.d/packages.toml`   | Homebrew taps and system packages                            |
| `conf.d/macos.toml`      | Dock and macOS defaults                                      |
| `config.personal.toml`   | Extras for personal machines, `-E personal`                  |
| `config.work.toml`       | Extras for work machines, `-E work`                          |
| `miserc.local.toml.tera` | Template for the uncommitted flavour marker                  |
| `mise.lock`              | Lockfile for tool versions with checksums                    |
| `@macos/settings.zsh`    | Privileged, host-scoped and collection-valued macOS settings |

> Anything in this repository with a `@` prefix is operating-system specific,
> and anything with a `_` prefix is expected to be linked anywhere.

When specifying paths inside mise config files,
ensure that paths are resolved against `{{ mise_config_dir }}`, as mise would otherwise use `$HOME` as the config root.

### Inspecting

```sh
mise bootstrap status
```

This will report every managed part.

The narrower commands can be used to only view a certain part:

```sh
mise bootstrap dotfiles status
mise bootstrap packages status
mise bootstrap macos defaults status
```

To exit with non-zero when something is out of sync, add `--missing` to the commands.

### Updating

```sh
git -C <checkout> pull
mise bootstrap --update --upgrade --yes
```

Note that tool versions updated this way will stay inside the ranges in `config.toml`.

### Customisation

Any `.zsh` file inside [`.zshcustom`](./zshcustom) is sourced at startup.

For machine-local values that should not be committed,
unmanaged Zsh files in the directory (e.g. `~/.zshcustom/extras.zsh`) can be utilised.

### Reverting

```sh
mise bootstrap dotfiles unapply
```

This will remove all symlinks created by mise,
but will not revert any installed packages and tools, or any applied macOS defaults.

To remove packages that are no longer declared in `config.toml`, use `packages prune`
(use `--dry-run` to check what would be removed, to be safe):

```sh
mise bootstrap packages prune
```

To target a specific package manager, use `--manager` (e.g. `--manager brew` or `--manager brew-cask`).
Note that `prune` will only remove casks installed by mise and is provably unchanged;
if those also need to be removed, use `--force`.

Mac App Store apps will have to be uninstalled manually.

## Acknowledgements

- [Github does dotfiles](https://dotfiles.github.io)
- [Dotfiles](https://github.com/mathiasbynens/dotfiles) by [@mathiasbynens](https://github.com/mathiasbynens),
  which is an amazing starting point for custom dotfiles
  (also contains the amazing `~/.macos` script!)
- [Dotfiles](https://github.com/driesvints/dotfiles) by [@driesvints](https://github.com/driesvints),
  which introduced me to tools like `mas` to manage apps
- [Dock.sh](https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8) by [@kamui545](https://github.com/kamui545),
  which is used here to programmatically setup the macOS Dock
