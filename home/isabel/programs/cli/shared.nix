{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.usrEnv.programs.cli.enable {
    home.packages = with pkgs;
      [
        # CLI packages from nixpkgs
        unzip
        ripgrep
        rsync
        fd
        jq
        dconf
        nitch
        exa
      ]
      ++ lib.optionals (osConfig.modules.usrEnv.programs.nur.enable && osConfig.modules.usrEnv.programs.nur.bella) [
        nur.repos.bella.bellado
        nur.repos.bella.catppuccinifier-cli
      ];
  };
}
