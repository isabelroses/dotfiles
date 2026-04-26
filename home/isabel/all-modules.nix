{ lib, modulesPath, ... }:
let
  mapMods = path: lib.map (subpath: "${modulesPath}/${path}/${subpath}");
in
{
  imports =
    mapMods "services" [
      # keep-sorted start
      "dunst.nix"
      "gpg-agent.nix" # needed by ssh
      "mako.nix"
      "pipewire.nix"
      "polybar.nix"
      "proton-pass-agent.nix" # needed by ssh
      "ssh-agent.nix" # needed by ssh
      "ssh-tpm-agent.nix" # needed by ssh
      "swaync.nix"
      "window-managers/hyprland.nix"
      "yubikey-agent.nix" # needed by ssh
      # keep-sorted end
    ]
    ++ mapMods "programs" [
      # keep-sorted start
      "aerc"
      "alacritty.nix"
      "anki"
      "atuin.nix"
      "bat.nix"
      "bottom.nix"
      "broot.nix"
      "btop.nix"
      "cava.nix"
      "chromium.nix"
      "delta.nix"
      "diff-highlight.nix" # git dep
      "diff-so-fancy.nix" # git dep
      "difftastic.nix" # git dep
      "direnv.nix"
      "discord.nix"
      "element-desktop.nix"
      "emacs.nix" # jujutsu dep
      "eza.nix"
      "fd.nix"
      "firefox"
      "fish.nix"
      "foot.nix"
      "freetube.nix"
      "fuzzel.nix"
      "fzf.nix"
      "gemini-cli.nix"
      "gh-dash.nix"
      "gh.nix"
      "ghostty.nix"
      "git.nix"
      "gitui.nix"
      "halloy.nix"
      "helix.nix"
      "home-manager.nix"
      "hyprlock.nix"
      "imv.nix"
      "jujutsu.nix"
      "k9s.nix"
      "kitty.nix"
      "lazygit.nix"
      "lsd.nix"
      "man.nix"
      "mangohud.nix"
      "micro.nix"
      "mpv.nix"
      "neovim.nix"
      "newsboat.nix"
      "nix-your-shell.nix"
      "obs-studio.nix"
      "opencode.nix"
      "patdiff.nix" # git dep
      "quickshell.nix"
      "qutebrowser.nix"
      "riff.nix" # git dep
      "rio.nix"
      "ripgrep.nix"
      "rofi.nix"
      "sioyek.nix"
      "skim.nix"
      "spotify-player.nix"
      "ssh.nix" # include this or face IR
      "starship.nix"
      "swaylock.nix"
      "television.nix"
      "thunderbird.nix"
      "tmux.nix"
      "tofi.nix"
      "vesktop.nix"
      "vicinae"
      "vim.nix"
      "vivid.nix"
      "vscode"
      "waybar.nix"
      "wezterm.nix"
      "wleave.nix"
      "wlogout.nix"
      "yazi.nix"
      "zathura.nix"
      "zed-editor.nix"
      "zellij.nix"
      "zk.nix"
      "zoxide.nix"
      # keep-sorted end
    ];
}
