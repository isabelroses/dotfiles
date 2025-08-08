{
  lib,
  pkgs,
  config,
  ...
}:

lib.mkIf config.garden.profiles.workstation.enable {
  garden.packages = {
    inherit (pkgs) lix-diff;
  };

  # nix.settings = {
  #   # all this work to get some extra maths functions because i love nix repl
  #   plugin-files = [
  #     (inputs'.tgirlpkgs.packages.lix-math.override { the_lix = config.nix.package; })
  #   ];
  # };
}
