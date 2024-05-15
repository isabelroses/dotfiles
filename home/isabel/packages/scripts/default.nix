{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib) getExe;
  inherit (builtins) readFile;
in
{
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "/etc/profiles/per-user/isabel/bin" # needed for darwin
    ];

    file = {
      # Preview files script for fzf tab
      ".local/bin/preview" = {
        source = getExe (
          pkgs.writeShellApplication {
            name = "preview";
            runtimeInputs =
              with pkgs;
              [
                bat
                eza
                catimg
              ]
              ++ [ inputs'.nekowinston-nur.packages.icat ];
            text = readFile ./preview.sh;
          }
        );
      };

      # Extract the compressed file with the correct tool based on the extension
      ".local/bin/extract" = {
        source = getExe (
          pkgs.writeShellApplication {
            name = "extract";
            runtimeInputs = with pkgs; [
              zip
              unzip
              gnutar
              p7zip
            ];
            text = readFile ./extract.sh;
          }
        );
      };

      ".local/bin/lockdiff" = {
        source = ./lockdiff.nu;
        executable = true;
      };

      # ".local/bin/calcgrades.py" = {
      #   source = pkgs.python3Packages.buildPythonPackage {
      #     name = "calcgrades";
      #     src = ./calcgrades.py;
      #   };
      # };
    };
  };
}
