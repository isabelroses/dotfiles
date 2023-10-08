{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"

    ./boot.nix
    ./iso.nix
    ./networking.nix
    ./nix.nix
  ];

  # FIXME: for some reason, we cannot boot off ventoy
  # and have to burn the iso to an entire USB with dd
  # dd if=result/iso/*.iso of=/dev/sdX status=progress

  users.extraUsers.root.password = "";

  # console locale #
  console = let
    variant = "u24n";
  in {
    # hidpi terminal font
    font = "${pkgs.terminus_font}/share/consolefonts/ter-${variant}.psf.gz";
    keyMap = "en";
  };

  # attempt to fix "too many open files"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "65536";
    }
  ];

  services.getty.helpLine =
    ''
      The "nixos" and "root" accounts have empty passwords.
      An ssh daemon is running. You then must set a password
      for either "root" or "nixos" with `passwd` or add an ssh key
      to /home/nixos/.ssh/authorized_keys be able to login.
      If you need a wireless connection, you may use networkmanager
      by invoking `nmcli` or `nmtui`, the ncurses interface.
    ''
    + optionalString config.services.xserver.enable ''
      Type `sudo systemctl start display-manager' to
      start the graphical user interface.
    '';

  # borrow some environment options from the minimal profile to save space
  environment = {
    noXlibs = mkDefault true; # trim inputs

    # no packages other than my defaults
    defaultPackages = [];

    # system packages for the base installer
    systemPackages = with pkgs; [
      nixos-install-tools
      gitMinimal
      neovim
      netcat
    ];

    # fix an annoying warning
    etc."mdadm.conf".text = ''
      MAILADDR root
    '';
  };

  # disable documentation to save space
  documentation = {
    enable = mkDefault false;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
  };

  # disable fontConfig to save space, we don't have a graphical environment on the ISO
  fonts.fontconfig.enable = lib.mkForce false;

  # disable sound related programs
  sound.enable = false;
}
