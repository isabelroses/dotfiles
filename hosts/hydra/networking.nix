{
  config,
  ...
}: {
  networking = {
    # useDHCP = false;
    networkmanager.enable = true;
    hostName = "hydra";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
}