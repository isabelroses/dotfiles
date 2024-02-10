<div align="center">
  <h1>isabel's dotfiles</h1>

  <img src="https://img.shields.io/github/stars/isabelroses/dotfiles?color=f5c2e7&labelColor=303446&style=for-the-badge&logo=starship&logoColor=f5c2e7">
  <img alt="ci" src="https://img.shields.io/github/actions/workflow/status/isabelroses/dotfiles/check.yml?label=build&color=a6e3a1&labelColor=303446&style=for-the-badge&logo=github&logoColor=a6e3a1" />
  <img src="https://img.shields.io/github/repo-size/isabelroses/dotfiles?color=fab387&labelColor=303446&style=for-the-badge&logo=github&logoColor=fab387">
</div>

### Install Notes

#### Linux

- Install [NixOS](https://nixos.org/download.html)
- Clone this repository to `~/.config/flake`
- Run `sudo nixos-rebuild switch --flake ~/.config/flake#<host>`

#### MacOS

- Install [homebrew](https://brew.sh/) 
> `curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash`
- Exclude nix from time machine backups 
> `sudo tmutil addexclusion -v /nix`
- `nix run nix-darwin -- switch --flake ~/.config/flake#<host> --experimental-features "nix-command flakes"`
- Then good news you can use the `rebuild` alias that exists for the future

### Config layout

- 🏠 [home](../home/)
- 🖥️ [hosts](../hosts/)
  - ☀️ [Amaterasu](../hosts/amatarasu/) My high-end gaming machine
  - 🪄 [Luz](../hosts/luz/) A server configuration for some of my infrastructure
  - 🐉 [Hydra](../hosts/hydra/) A super mid spec laptop
  - ⚸ [Lilith](../hosts/lilith/) A NixOS ISO image that can be quickly deployed and accessed via ssh
- 📖 [lib](../lib/) Useful repeated functions
- 🧩 [flake](../flake/) NixOS parts breaking down the complex configuration into smaller more manageable chunks
- 🔌 [modules](../modules/)
  - [common](../modules/base/) The base configuration settings, which are common between all systems
    - [base](../modules/base/common/) Core parts of the configuration
    - [options](../modules/base/options/) Selectable settings that can be used to toggle certain settings
  - [extra](../modules/extra) Extra configuration modules, for home-manager and NixOS
  - [profiles](../modules/profiles/) System type configurations (e.g. laptop, servers, desktop)

<details>
<summary> Hyprland Shortcuts </summary>

| Shortcut                        | What it does               |
| ------------------------------- | -------------------------- |
| <kbd>SUPER+RETURN</kbd>         | open terminal              |
| <kbd>SUPER+B</kbd>              | open browser               |
| <kbd>SUPER+C</kbd>              | open editor                |
| <kbd>SUPER+O</kbd>              | open notes                 |
| <kbd>SUPER+E</kbd>              | open file manager          |
| <kbd>SUPER+Q</kbd>              | quit                       |
| <kbd>SUPER+D</kbd>              | launcher                   |
| <kbd>SUPER+F</kbd>              | full screen                |
| <kbd>SUPER+[number]</kbd>       | open workspace [number]    |
| <kbd>SUPER+SHIFT+[number]</kbd> | move to workspace [number] |

</details>

### Some Awesome people

[NotAShelf](https://github.com/notashelf/nyx) - [numtide/srvos](https://github.com/numtide/srvos) - [nullishamy](https://github.com/nullishamy/derivation-station) - [nekowinston](https://github.com/nekowinston/dotfiles) - [getchoo](https://github.com/getchoo) - [nyxkrage](https://github.com/nyxkrage)
