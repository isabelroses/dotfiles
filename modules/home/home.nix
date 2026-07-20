{ pkgs, osConfig, ... }:
{
  home = {
    stateVersion = osConfig.garden.system.stateVersion;

    # WARNING: this is an experimental option added by my fork of home-manager
    linker = {
      backend = "smfh";

      smfh.package = pkgs.smfh.overrideAttrs (oa: {
        patches = oa.patches ++ [
          (pkgs.fetchpatch2 {
            url = "https://github.com/feel-co/smfh/commit/3fef284b6d973aac3473861ac70a60c4ab56e743.patch";
            hash = "sha256-/9Wl4QCE9jyOx/KvwKFY09ut2WpaxP//LOmS6r7A2Uw=";
          })
        ];
      });
    };
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
}
