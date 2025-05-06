{
  self,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    discord = mkProgram pkgs "discord" {
      package.default = pkgs.discord.override {
        withOpenASAR = true;
        withVencord = true;
      };
    };
  };
}
