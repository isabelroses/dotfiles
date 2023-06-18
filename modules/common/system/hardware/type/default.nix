{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./laptop
    #../desktop
    #./desktop
    #./lite
  ];
}
