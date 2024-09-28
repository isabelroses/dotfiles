{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/sccache";
  };

  systemd.tmpfiles.settings."10-sccache".${cfg.cacheDir}.z = {
    mode = "770";
    user = "root";
    group = "nixbld";
    age = "-";
    argument = "-";
  };

  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  nixpkgs.overlays =
    mkIf (config.programs.ccache.enable && config.programs.ccache.packageNames == [ ])
      [
        (_: super: {
          ccacheWrapper = super.ccacheWrapper.override {
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_DIR="${config.programs.ccache.cacheDir}"
              export CCACHE_UMASK=007
              export CCACHE_SLOPPINESS=include_file_mtime,time_macros
              export CCACHE_NODIRECT=1
              if [ ! -d "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' does not exist"
                echo "Please create it with:"
                echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                echo "====="
                exit 1
              fi
              if [ ! -w "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                echo "Please verify its access permissions"
                echo "====="
                exit 1
              fi
            '';
          };
        })
      ];
}
