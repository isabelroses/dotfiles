### 🖥️ Systems

| Name      | Main User | Type    | OS    | Extra Details |
| --------- | --------- | ------- | ----- | ------------- |
| amaterasu | isabel    | Desktop | NixOS | A powerful desktop dual booting windows 11 |
| athena    | isabel    | Hybrid  | NixOS | My oldest laptop, altogh this flake still supports it, its barely in use |
| bmo       | robin     | Laptop  | NixOS | Robin's laptop |
| aphrodite | isabel    | Sever   | NixOS | The host of most tgirl.cloud services |
| lilith    | n/a       | Iso     | NixOS | An iso image of my NixOS configuration, used to install NixOS on new systems |
| minerva   | isabel    | Server  | NixOS | This is the orginal server, hosting most of my personal services |
| skadi     | isabel    | Server  | NixOS | Oracle free server, mostly used for the pds and aarch64 builds |
| tatsumaki | isabel    | Laptop  | macOS | A macbook air, given to me by uni, almost exclusively used at uni |
| valkyrie  | isabel    | WSL2    | NixOS | This is my WSL2 instance, installed on amaterasu |
| wisp      | robin     | WSL2    | NixOS | Robin's WSL2 instance, installed on her desktop |


### 🧩 Modules

* [flake](https://github.com/isabelroses/dotfiles/tree/main/modules/flake/) - modules which are used to build the flake outputs
* [generic](https://github.com/isabelroses/dotfiles/tree/main/modules/generic/) - modules which are intended to work with any module system (e.g. home-manager, nix-darwin, etc.)
* [nixos](https://github.com/isabelroses/dotfiles/tree/main/modules/nixos/) - modules which work on NixOS
* [base](https://github.com/isabelroses/dotfiles/tree/main/modules/base/) - modules which work on either NixOS or macOS
* [darwin](https://github.com/isabelroses/dotfiles/tree/main/modules/darwin/) - modules which work on macOS
* [home](https://github.com/isabelroses/dotfiles/tree/main/modules/home/) - modules which are used to configure home-manager
* [iso](https://github.com/isabelroses/dotfiles/tree/main/modules/iso/) - modules which are used to build isos
* [wsl](https://github.com/isabelroses/dotfiles/tree/main/modules/wsl/) - modules which work on WSL2
