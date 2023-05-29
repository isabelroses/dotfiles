# Littral Trash

Still just learning nix. However if you are desprate enough to install this:

```bash
git clone -b nixos https://github.com/isabelroses/dotfiles .setup
cd .setup
sudo nixos-rebuild switch --flake .#hydra
```
NOTE: THIS WILL NOT RUN UNLESS YOU EITHER REMOVE THE CLOUDFLARED MODLUES OR CREATE AND `env.nix` FILE AND HAVE A CLOUDFLARED TOKEN THERE.

Then enjoy these hot trash dots
