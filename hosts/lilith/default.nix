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

  console = let
    variant = "u24n";
  in {
    # hidpi terminal font
    font = "${pkgs.terminus_font}/share/consolefonts/ter-${variant}.psf.gz";
    keyMap = "en";
  };

  # fix: "too many open files"
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

  # Use environment options, minimal profile, to save space
  environment = {
    noXlibs = mkDefault true;

    # no packages other, other then the ones i provide
    defaultPackages = [];

    # needed packages for the installer
    systemPackages = with pkgs; [
      nixos-install-tools
      gitMinimal
      neovim
      netcat
    ];

    # fix annoying warning
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

  # disable fontConfig to save space, not like we have a GUI anyways
  fonts.fontconfig.enable = lib.mkForce false;

  # disable sound related programs, more space saving
  sound.enable = false;
}
