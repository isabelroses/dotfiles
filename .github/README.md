<div align="center">
  <img alt="dots src="./dots.svg" />
  <h1>isabel's dotfiles</h1>

  <img alt="stars" src="https://img.shields.io/github/stars/isabelroses/dotfiles?color=f5c2e7&labelColor=303446&style=for-the-badge&logo=starship&logoColor=f5c2e7">
  <img alt="ci" src="https://img.shields.io/github/actions/workflow/status/isabelroses/dotfiles/check.yml?label=build&color=a6e3a1&labelColor=303446&style=for-the-badge&logo=github&logoColor=a6e3a1" />
  <img alt="repo size" src="https://img.shields.io/github/repo-size/isabelroses/dotfiles?color=fab387&labelColor=303446&style=for-the-badge&logo=github&logoColor=fab387">
</div>

<br />

<!--toc:start-->
- [What does this repo provided](#what-does-this-repo-provided)
  - [Shortcuts](#shortcuts)
- [Config layout](#config-layout)
- [Install Notes](#install-notes)
  - [NixOS](#nixos)
  - [macOS](#macos)
- [Awesome people/projects](#awesome-peopleprojects)
<!--toc:end-->

### What does this repo provided

- Several applications and tools for the same purpose, so you can choose the one that best suits your needs
  - `neovim`, `micro` and `vscode` for text editing
  - `firefox` and `chromium` for web browsing
  - `alacritty`, `kitty` and `wezterm` for terminal emulators
  - `bash`, `zsh`, `fish` and `nushell` for shells
- Modular configuration, so you can add or remove parts of the configuration
- Sensible defaults, so you can get started quickly
- [Catppuccin](https://github.com/catppuccin/catppucin) everywhere

<details>
<summary>

#### Shortcuts
</summary>

| SKHD Shortcut                   | Hyprland Shortcut               | What it does               |
| ------------------------------- | ------------------------------- | -------------------------- |
| <kbd>CMD+RETURN</kbd>           | <kbd>SUPER+RETURN</kbd>         | open terminal              |
|                                 | <kbd>SUPER+B</kbd>              | open browser               |
|                                 | <kbd>SUPER+C</kbd>              | open editor                |
|                                 | <kbd>SUPER+O</kbd>              | open notes                 |
|                                 | <kbd>SUPER+E</kbd>              | open file manager          |
| <kbd>CMD+Q</kbd>                | <kbd>SUPER+Q</kbd>              | quit                       |
| <kbd>CMD+D</kbd>                | <kbd>SUPER+D</kbd>              | launcher                   |
|                                 | <kbd>SUPER+F</kbd>              | full screen                |
| <kbd>CMD+CTRL+[number]</kbd>    | <kbd>SUPER+[number]</kbd>       | open workspace [number]    |
| <kbd>CMD+SHIFT+[number]</kbd>   | <kbd>SUPER+SHIFT+[number]</kbd> | move to workspace [number] |

</details>

### Config layout

- 🏠 [home](../home/)
- 🖥️ [hosts](../hosts/)
  - ☀️ [Amaterasu](../hosts/amatarasu/) My high-end gaming machine
  - 🐉 [Hydra](../hosts/hydra/) A super mid spec laptop
  - ⚸ [Lilith](../hosts/lilith/) A NixOS ISO image that can be quickly deployed and accessed via ssh
  - 🪄 [Luz](../hosts/luz/) A server configuration for some of my infrastructure
  - 𖤍 [Valkyrie](../hosts/valkyrie/) A WSL2 host, designed to be a development environment on Windows
  - 💮 [Tatsumaki](../hosts/tatsumaki/) A MacBook Air, configured to last a whole day of university
- 📚 [lib](../lib/) Useful repeated functions
- 🧩 [parts](../parts/) NixOS parts breaking down the complex configuration into smaller more manageable chunks
- 📝 [docs](../docs/) Documentation for the configuration which can be found [here](https://isabelroses.github.io/dotfiles/)
- 🔌 [modules](../modules/)
  - [base](../modules/base/) The base configuration settings, which are common between all systems
  - [darwin](../modules/darwin/) Configuration modules for exclusivly darwin systems
  - [nixos](../modules/nixos/) Configuration modules for exclusivly nixos systems
  - [extra](../modules/extra) Extra configuration modules, for home-manager and Nix Darwin and NixOS
  - [profiles](../modules/profiles/) System type configurations (e.g. laptop, servers, desktop)

### Install Notes

#### NixOS

- Install [NixOS](https://nixos.org/download), you might need to follow the [manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation)
  You might want to use the [lilith iso configuration](../hosts/lilith/), provided in this repository
  - To build it you can run `nix build .#images.lilith`.
  - Or you can download it from the [release page](https://github.com/isabelroses/dotfiles/releases/tag/isos).
- Clone this repository to `~/.config/flake`
- Run `sudo nixos-rebuild switch --flake ~/.config/flake#<host>`

#### macOS

- Install [Nix](https://nixos.org/manual/nixos/stable/index.html#sec-installation) the package manager
  > `sh <(curl -L https://nixos.org/nix/install)`
- Install [homebrew](https://brew.sh/) 
  > `curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash`
- Exclude nix from time machine backups 
  > `sudo tmutil addexclusion -v /nix`
- `nix run nix-darwin -- switch --flake ~/.config/flake#<host> --experimental-features "nix-command flakes"`
- Then good news you can use the `rebuild` alias that exists for the future

### Awesome people/projects

[NotAShelf](https://github.com/notashelf/nyx) - [numtide/srvos](https://github.com/numtide/srvos) - [nullishamy](https://github.com/nullishamy/derivation-station) - [nekowinston](https://github.com/nekowinston/dotfiles) - [getchoo](https://github.com/getchoo) - [nyxkrage](https://github.com/nyxkrage)
