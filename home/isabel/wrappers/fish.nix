# https://github.com/viperML/dotfiles/blob/master/modules/wrapper-manager/fish/default.nix
{ pkgs, lib, ... }:
let
  inherit (lib.strings) concatStringsSep;

  inherit (pkgs) writeTextDir;
  vendorConf = "share/fish/vendor_conf.d";

  mkInitScript = pkg: pkgs.runCommandLocal "${pkg.pname}-init.fish" { buildInputs = [ pkg ]; };

  initScripts = [
    (mkInitScript pkgs.zoxide ''
      zoxide init fish --cmd cd > $out
    '')
    (mkInitScript pkgs.direnv ''
      direnv hook fish > $out
    '')
    (mkInitScript pkgs.starship ''
      starship init fish > $out
    '')
    (mkInitScript pkgs.nix-your-shell ''
      nix-your-shell fish > $out
    '')
    (pkgs.runCommandLocal "atuin-fish-config.fish"
      {
        nativeBuildInputs = [
          pkgs.writableTmpDirAsHomeHook
          pkgs.atuin
        ];
      }
      ''
        atuin init fish --disable-up-arrow > "$out"
      ''
    )
  ];

  config =
    writeTextDir "${vendorConf}/isabel_config.fish"
      # fish
      ''
        # source env stuff, generate this with {option}`programs.fish.useBabelFish`
        source /etc/fish/nixos-env-preinit.fish

        alias df 'df -h'
        alias eza 'eza --icons auto --group --group-directories-first --header --no-permissions --octal-permissions'
        alias fd 'fd --hidden'
        alias jctl 'journalctl -p 3 -xb'
        alias la 'eza -a'
        alias lg lazygit
        alias ll 'eza -l'
        alias lla 'eza -la'
        alias ls eza
        alias lt 'eza --tree'
        alias mkdir 'mkdir -pv'
        alias rs 'systemctl reboot'

        if status is-interactive
          set -gx DIRENV_LOG_FORMAT ""
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
          ${concatStringsSep "\nsource " initScripts}
        end
      '';
in
{
  wrappers.fish = {
    basePackage = pkgs.fish;
    extraPackages = [ pkgs.zoxide ];
    programs.fish = {
      wrapFlags = [
        "--prefix"
        "XDG_DATA_DIRS"
        ":"
        (lib.makeSearchPathOutput "out" "share" [
          config
        ])
      ];
    };
  };
}
