{
  config = {
    # auto-run programs using nix-index-database
    home.sessionVariables.NIX_AUTO_RUN = "1";

    programs = {
      nix-index = {
        enable = true;

        # link nix-index database to ~/.cache/nix-index
        symlinkToCacheHome = true;
      };

      nix-index-database.comma.enable = true;
    };
  };
}
