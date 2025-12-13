# if you want my honest opinion on crypto i hate it. but this is basically free
# money since i have a good computer and my electric is free, so why not
{
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib) mkServiceOption;
in
{
  options.garden.services.xmrig = mkServiceOption "xmrig" { };

  config = {
    services.xmrig = {
      inherit (config.garden.services.xmrig) enable;

      settings = {
        autosave = true;
        cpu = true;
        opencl = false;
        cuda = {
          enabled = true;
          loader = "${pkgs.pkgsCuda.xmrig-cuda}/lib/libxmrig-cuda.so";
        };

        pools = [
          {
            url = "pool.hashvault.pro:443";
            user = "43eSyrtuhm2JSoot8Kp74ANpabMmHaj5uKtyBwa4ZtixA5gcWxxPFj2PnxU7dDyfs4MLqcKSRbmvgCRXqfKkhiRoNsjTkPU";
            pass = config.networking.hostName;
            keepalive = true;
            tls = true;
            tls-fingerprint = "420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14";
          }
        ];
      };
    };
  };
}
