# pinned dashboard-icons; to bump, change rev and re-prefetch each hash
{ fetchurl }:
let
  rev = "9d019529dfd4431770e7380bfafd6628800b7986";
  icon =
    path: hash:
    fetchurl {
      url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/${rev}/${path}";
      inherit hash;
    };
in
{
  alloy = icon "svg/alloy.svg" "sha256-+41oDWvA5CmWixzrISj0R5ZcwWavvMcq7t3/BV1+NVE=";
  arr = icon "svg/servarr.svg" "sha256-CKRTXxVLaU4RsSjkyHxG6RUQqvV4ruFuuIHstFW8FFU=";
  atuin = icon "svg/atuin.svg" "sha256-R3ZS1BGpldZwtc3KCr5F1/wOxAx92la9OS8gBKjsjf8=";
  borgbackup = icon "svg/borg.svg" "sha256-6CenSJG3shyhvI52ZRIcZ2ESzKktDHLDElclTmUz5AA=";
  cloudflared = icon "svg/cloudflare.svg" "sha256-jRiABG7SI/+0ymYNT1LP+YbW2zEOJdh82C7M0CS0YfU=";
  cobalt = icon "svg/cobalt.svg" "sha256-hDGGU3MjapcB3VLUokxsqkdZ9xYYAJKdl3AB/3+JWiI=";
  forgejo = icon "svg/forgejo.svg" "sha256-rFqblD/6KwswWk6iHdi3VkyKjswI0uPWEnT35hlz56U=";
  gatus = icon "svg/gatus.svg" "sha256-kB4HLK/TDC1ZoXEHdKlz6YNwadUuN/6WlXT9uzQrRQE=";
  grafana = icon "svg/grafana.svg" "sha256-jzKJcHPuk1lKsjOUgu8hyjdnBEBV2oniuvkGbSVZLfc=";
  home-assistant = icon "svg/home-assistant.svg" "sha256-FGs2a4wJUCdCAlxLyk4Cno5KGyd9uDfVmiO5OUDr4OA=";
  immich = icon "svg/immich.svg" "sha256-pdSkOJnmP/x+lyRgNPf2PN/cQQqoA8VxPVRSkGAcTYk=";
  jellyfin = icon "svg/jellyfin.svg" "sha256-f1PPCD27MRnsjFrL2AScUDMidhfkYVQPcFkawQkSQwY=";
  kanidm = icon "svg/kanidm.svg" "sha256-dd7FbGp6zlf/8e9pqvzFMg/lQ8/9hwKDCIliE3enuCQ=";
  linkwarden = icon "png/linkwarden.png" "sha256-NIp0BhzkB78d7kHrx0srSMvKcGCoB1VuFRR7o4Cvto4=";
  loki = icon "svg/loki.svg" "sha256-hMCHk+wFMYckXPHxV+zviR2ZJFMOoYedfQZIIBUQhe0=";
  matrix = icon "svg/matrix-light.svg" "sha256-njB5Iy7MypWlR7j6JDeIl+RBOmCGktTEnEiIcxiHycM=";
  nginx = icon "svg/nginx.svg" "sha256-OGDw05nkj8qjDysh081eDWkyZxQPHijLLTQZgauNL0w=";
  os-android = icon "svg/android.svg" "sha256-k+ZYDsKTknhHN4HMGEEhgPMOaiknlsg4h0DBeDB4c0s=";
  os-apple = icon "png/apple-light.png" "sha256-kiuRZ05JWgv+nFiPKSMSai6ox1fWuLpSaoPdfwAzU6g=";
  os-nixos = icon "png/nixos.png" "sha256-IM+VMjejwv0CJ5MMixAWXPHL9aNMwx+K4Nfy1opXOHY=";
  os-raspberry-pi = icon "svg/raspberry-pi.svg" "sha256-7rUZaGZeUaS7keBSoVk73RZlkJ96/o9sWZm9UEUkYLE=";
  os-ubuntu = icon "svg/ubuntu-linux.svg" "sha256-aLWcNjIH90cBXFZWSXRV+3iyK4ebdEAEBu+1BG5QPM0=";
  pds = icon "svg/bluesky.svg" "sha256-DPra4pKDoB0gI/GhP9nad5NZIcYYXU7vD1KqLQFHoU0=";
  pi-hole = icon "svg/pi-hole.svg" "sha256-RJRONKcheXwycc/GsV3/gc1vu/ZsfJbaU6NO05vgbqU=";
  postgresql = icon "svg/postgres.svg" "sha256-hyGYghKvxRNK8oxQYB2H5vPKZI6OBPZrBFPcH5Em41k=";
  prometheus = icon "svg/prometheus.svg" "sha256-uHGGmK2K+p6lJqYIHxB39h2XSmawZwBUaWZc+viBYqY=";
  pufferpanel = icon "png/pufferpanel.png" "sha256-fqxCxMqLbBuGCPKWc5AXXklW7BSsq291577ZLIdtvvg=";
  redis = icon "svg/redis.svg" "sha256-nD1KZFgJRoelsDWx2JC4CLPW0GWEYl4MvjgFTSTjuG0=";
  umami = icon "svg/umami-light.svg" "sha256-pxtMPtbhr08g+4fqdxujqLHc+GnnBnSZR5zCJrr1Z18=";
  vaultwarden = icon "svg/vaultwarden-light.svg" "sha256-kk0h8OUl1a4gigo3TbUiHgZZ/U7TisKQ+eh14W9nezU=";
  wakapi = icon "svg/wakapi.svg" "sha256-QMAB0lrV/PaN3jERZPeB3Dequ8XWwq+qsMooEp/WlqY=";
}
