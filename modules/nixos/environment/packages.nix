{
  lib,
  pkgs,
  config,
  ...
}:
{
  # remove the core packages and instead i'll add them myself with packages I choose
  environment.corePackages = lib.mkForce [ ];

  # we somewhat need to search for them beacuse they are not all in one place
  # https://github.com/search?q=repo%3ANixOS%2Fnixpkgs+corePackages+path%3Anixos%2Fmodules&type=code
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
      uutils-procps # replaces: procps
      su
      time
      util-linux
      which
      zstd
      ;

    # https://github.com/NixOS/nixpkgs/blob/f6521800aff648b639ec808d7079cb2a90d1652b/nixos/modules/config/system-path.nix#L50
    inherit (pkgs.stdenv.cc) libc;

    # https://github.com/NixOS/nixpkgs/blob/f6521800aff648b639ec808d7079cb2a90d1652b/nixos/modules/tasks/network-interfaces.nix#L1771-L1777
    inherit (pkgs)
      host
      uutils-hostname # replaces: hostname
      iproute2
      iputils
      ;

    # so odd
    # https://github.com/NixOS/nixpkgs/blob/f6521800aff648b639ec808d7079cb2a90d1652b/nixos/modules/programs/ssh.nix#L338
    openssh = config.services.openssh.package;
  };
}
