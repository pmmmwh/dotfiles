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

Then, run `bootstrap`:

```sh
mise bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
```

`<checkout>` is wherever you want the clone to live, and `--config-dir .` links
`~/.config/mise` to it, so the repository _is_ mise's global config from the
first run on: later commands need neither `--from` nor a working directory
inside the clone.

**Personal Stuff**

On my personal machines, `-E personal` is added to pull in extra apps and tools:

```sh
mise -E personal bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
```

This will install system packages, clone Zsh plugins, link the dotfiles,
write macOS defaults and install tool chains.

**Work Stuff**

On work machines, `-E work` pulls in work-only tooling instead:

```sh
mise -E work bootstrap --from https://github.com/pmmmwh/dotfiles.git --from-dir <checkout> --config-dir . --yes
```

The chosen environment is recorded in `miserc.local.toml`, which is not
committed, so `-E` is only needed on this first run.

**macOS Settings**

Some macOS defaults cannot be expressed in mise, and they are applied as a separate step:

```sh
mise run macos-settings
```

mise prints a reminder when it writes a preference that needs a relaunch.
This task ends by restarting Dock, Finder and SystemUIServer.

## Operations

### Structure

This repository is mise's global config directory, so its files are the ones
mise reads from `~/.config/mise`.

| Where                    | What                                                          |
| ------------------------ | ------------------------------------------------------------- |
| `config.toml`            | Tools, settings, dotfiles, vars, plugin repos, login shell    |
| `conf.d/packages.toml`   | Homebrew taps and system packages                             |
| `conf.d/macos.toml`      | Dock and macOS defaults                                       |
| `config.personal.toml`   | Extra tools and packages for personal machines, `-E personal` |
| `config.work.toml`       | Extra packages for work machines, `-E work`                   |
| `miserc.local.toml.tera` | Renders the environment marker, which is not committed        |
| `mise.lock`              | Locked tool versions and checksums, committed                 |
| `@macos/settings.zsh`    | Privileged, host-scoped and collection-valued macOS settings  |

Anything under `@` is operating-system specific, and anything under `_` is not linked anywhere.
Paths inside these files resolve against `{{ mise_config_dir }}`, not the working directory,
because for global config mise treats `$HOME` as the config root.

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

### Updating

```sh
git -C <checkout> pull
mise bootstrap --update --upgrade --yes
```

`--update` refreshes package metadata and pulls the Zsh plugin repositories,
`--upgrade` upgrades what is already installed instead of only filling in what is missing.
Neither needs `-E` nor a working directory inside the clone.

Tool versions stay inside the ranges in `config.toml`,
so widening one (e.g. `node = "24"` to `"26"`) remains a manual edit.
Both flags rewrite `mise.lock`, which is committed;
mise rebuilds it from the current requests, so it covers every platform rather than only this machine.

### Customisation

Any `.zsh` file inside [`.zshcustom`](./zshcustom) is sourced at startup.
If you have machine-local values that should not be committed,
you can utilise unmanaged Zsh files in the directory (e.g. `~/.zshcustom/extras.zsh`).

### Reverting

```sh
mise bootstrap dotfiles unapply
```

This will remove all symlinks mise created,
but will not revert any installed packages and tools, or any applied macOS defaults.

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
  which introduced me to tools like `mas` to manage apps
- [Dock.sh](https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8) by [@kamui545](https://github.com/kamui545),
  which is used here to programmatically setup the macOS Dock
