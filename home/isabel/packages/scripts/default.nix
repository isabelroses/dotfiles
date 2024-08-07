{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib.meta) getExe;
in
{
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      # I relocated this too the fish config, such that it would fix a issue where git would use the wrong version
      # "/etc/profiles/per-user/isabel/bin" # needed for darwin
    ];

    file = {
      # Preview files script for fzf tab
      ".local/bin/preview" = {
        source = getExe (
          pkgs.writeShellApplication {
            name = "preview";
            runtimeInputs = builtins.attrValues { inherit (pkgs) bat eza catimg; };
            text = readFile ./preview.sh;
          }
        );
      };

      ".local/bin/icat" = {
        source = getExe (
          pkgs.writeShellApplication {
            name = "icat";
            text = readFile ./icat.sh;
          }
        );
      };

      # Extract the compressed file with the correct tool based on the extension
      ".local/bin/extract" = {
        source = getExe (
          pkgs.writeShellApplication {
            name = "extract";
            runtimeInputs = builtins.attrValues {
              inherit (pkgs)
                zip
                unzip
                gnutar
                p7zip
                ;
            };
            text = readFile ./extract.sh;
          }
        );
      };

      ".local/bin/lockdiff" = {
        source = ./lockdiff.nu;
        executable = true;
      };

      ".local/bin/nixpkgs-dev" = {
        text = "nix develop ${osConfig.garden.environment.flakePath}#nixpkgs";
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
