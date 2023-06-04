{
  config,
  lib,
  pkgs,
  ...
}: let
  fromYAML = f: let
    jsonFile =
      pkgs.runCommand "in.json"
      {
        nativeBuildInputs = [pkgs.jc];
      } ''
        jc --yaml < "${f}" > "$out"
      '';
  in
    builtins.elemAt (builtins.fromJSON (builtins.readFile jsonFile)) 0;
in {
  programs.lazygit = {
    enable = true;
    settings =
      {}
      // fromYAML (pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "lazygit";
          rev = "f01edfd57fa2aa7cd69a92537a613bb3c91e65dd";
          sha256 = "sha256-zjzDtXcGtUon4QbrZnlAPzngEyH56yy8TCyFv0rIbOA=";
        }
        + "/themes/mocha.yml");
  };
}