{ lib, pkgs, ... }:
{
  # remove the core packages and instead i'll add them myself with packages I choose
  environment.corePackages = lib.mkForce [ ];

  garden.packages = {
    # https://github.com/NixOS/nixpkgs/blob/e6eae2ee2110f3d31110d5c222cd395303343b08/nixos/modules/config/system-path.nix#L11-L41
    inherit (pkgs)
      acl
      attr
      bashInteractive # bash with ncurses support
      bzip2
      uutils-coreutils-noprefix # replaces: coreutils-full
      cpio
      curl
      uutils-diffutils # replaces: diffutils
      uutils-findutils # replaces: findutils
      gawk
      getent
      getconf
      gnugrep
      gnupatch
      uutils-sed # replaces gnused
      gnutar
      gzip
      xz
      less
      libcap
      ncurses
      netcat
      mkpasswd
      procps
      su
      time
      util-linux
      which
      zstd
      ;
  };
}
