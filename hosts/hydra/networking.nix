{
  config,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    hostName = "hydra";
  };
}