{
  config,
  pkgs,
  inputs',
  lib,
  ...
}: {
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "/etc/profiles/per-user/isabel/bin" # needed for darwin
    ];

    file = {
      # Preview files script for fzf tab
      ".local/bin/preview" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "preview";
          text = import ./preview.nix {inherit inputs' lib pkgs;};
        });
      };

      # Extract the compressed file with the correct tool based on the extension
      ".local/bin/extract" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "extract";
          text = import ./extract.nix {inherit lib pkgs;};
        });
      };
    };
  };
}
