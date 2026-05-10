{ self, config, ... }:
let
  inherit (self.lib) anyHome;

  qh = anyHome config;
in
{
  # home-manager is so strange and needs these declared multiple times
  programs = {
    zsh.enable = qh (c: c.programs.zsh.enable);

    fish = {
      enable = qh (c: c.programs.fish.enable);

      # fish goes brr
      useBabelfish = true;
    };
  };
}
