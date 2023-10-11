{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    file = {
      ".local/bin/preview" = {
        # Preview files script for fzf tab
        executable = true;
        text = import ./preview.nix {inherit lib pkgs;};
      };

      ".local/bin/extract" = {
        # Extract the compressed file with the correct tool based on the extension
        executable = true;
        text = import ./extract.nix {inherit lib pkgs;};
      };
    };
  };
}
