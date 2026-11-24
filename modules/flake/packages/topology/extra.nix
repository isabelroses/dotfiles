# what fleet.toml doesn't know: the network around the fleet, devices that
# aren't hosts, and how to draw the hosts the flake doesn't build
{
  router = {
    name = "bingus";
    info = "Cudy WR3000 v2";
    cidr = "192.168.10.0/24";
  };

  tailnet = "alewife-galaxy.ts.net";

  # merged over fleet.toml
  hosts = {
    amity = {
      kind = "oracle · ubuntu · aarch64";
      os = "ubuntu";
    };

    pi = {
      kind = "raspberry pi · dietpi";
      os = "raspberry-pi";
      location = "home";
      ipv4 = "192.168.10.5";
      tailnetIp = "100.92.186.13";
      services = [ "pi-hole" ];
    };

    pixel = {
      kind = "pixel 7a · android";
      os = "android";
      location = "roaming";
      tailnetIp = "100.100.17.39";
    };
  };
}
