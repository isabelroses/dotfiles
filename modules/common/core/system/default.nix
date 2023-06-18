_: {
  imports = [
    ./locale.nix
    ./environment.nix
    ./security.nix
    ./services.nix
    ./programs.nix
  ];

  # Systemd OOMd
  # Fedora enables these options by default. See the 10-oomd-* files here:
  # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
  systemd.oomd = {
    enableRootSlice = true;
    enableUserServices = true;
  };
}
