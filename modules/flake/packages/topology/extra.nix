# what fleet.toml doesn't know
{
  router = {
    name = "bingus";
    info = "Cudy WR3000 v2";
    cidr = "192.168.10.0/24";
  };

  tailnet = "alewife-galaxy.ts.net";

  # unlisted hosts are in the cloud
  home = [
    "amaterasu"
    "freyja"
    "pi"
  ];
  roaming = [
    "pixel"
    "tatsumaki"
  ];

  # merged over fleet.toml
  hosts = {
    amaterasu.tailnetIp = "100.88.249.103";
    freyja.tailnetIp = "100.69.230.34";
    isis.tailnetIp = "100.117.185.89";
    minerva.tailnetIp = "100.92.18.61";
    skadi.tailnetIp = "100.110.118.65";
    tatsumaki.tailnetIp = "100.122.131.85";

    amity = {
      kind = "oracle · ubuntu · aarch64";
      os = "ubuntu";
      tailnetIp = "100.98.147.89";
      services = [
        "alloy"
        "cloudflared"
        "cobalt"
        "linkwarden"
        "pufferpanel"
        "umami"
      ];
    };

    pi = {
      kind = "raspberry pi · dietpi";
      os = "raspberry-pi";
      ipv4 = "192.168.10.5";
      tailnetIp = "100.92.186.13";
      services = [ "pi-hole" ];
    };

    pixel = {
      kind = "pixel 7a · android";
      os = "android";
      tailnetIp = "100.100.17.39";
    };
  };
}
