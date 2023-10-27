<div align="center">
<h1>
<img width="96" src="./assets/flake.svg"></img> <br>
  isabel's dotfiles
</h1>
  <img src="https://img.shields.io/github/stars/isabelroses/dotfiles?color=f5c2e7&labelColor=303446&style=for-the-badge&logo=starship&logoColor=f5c2e7">
  <img alt="ci" src="https://img.shields.io/github/actions/workflow/status/isabelroses/dotfiles/check.yml?label=build&color=a6e3a1&labelColor=303446&style=for-the-badge&logo=github&logoColor=a6e3a1" />
  <img src="https://img.shields.io/github/repo-size/isabelroses/dotfiles?color=fab387&labelColor=303446&style=for-the-badge&logo=github&logoColor=fab387">
</div>

### config layout

- 🏠 [home](../home/)
- 🖥️ [hosts](../hosts/)
  - ☀️ [amatarasu](../hosts/amatarasu/) My high end gameing machine
  - 👴 [bernie](../hosts/bernie/) A server configuration for some of my infastrucior
  - 🇧[beta](../hosts/beta/) A consept configuration for a new local server
  - 🐉 [hydra](../hosts/hydra/) A super mid spec laptop
  - ⚸ [lilith](../hosts/lilith/) A nixos iso image that can be qickly deployed and acessed via ssh
- 📖 [lib](../lib/) Useful repeated functions
- 🧩 [parts](../parts/) Nixos parts breaking down the complex confiuration into smaller more managable chuncks
- 🔌 [modules](../modules/)
  - [common](../modules/common/) Common configuration settings
    - [core](../modules/common/core/) Core parts of the configuration
    - [secrets](../modules/common/secrets/) Sops secured system secrets
    - [types](../modules/common/types/) System type configurations (e.g. laptop, servers, desktop)
  - [extra](../modules/extra/) Prebuilt configrations & spare parts
  - [options](../modules/common/options/) Selecteable settings that can be used to toggle certain settings

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
| <kbd>SUPER+F</kbd>              | fullscreen                 |
| <kbd>SUPER+[number]</kbd>       | open workspace [number]    |
| <kbd>SUPER+SHIFT+[number]</kbd> | move to workspace [number] |

</details>

### credits

- [NotAShelf](https://github.com/notashelf/nyx) - The carry (and basicly half this repo)
- [numtide/srvos](https://github.com/numtide/srvos) - Server stuff
- [nullishamy](https://github.com/nullishamy/derivation-station) - Home-Manager Stuff
- [nekowinston](https://github.com/nekowinston/dotfiles) - Basicly answers all my questions
- [getchoo](https://github.com/getchoo) - For several things here and there
