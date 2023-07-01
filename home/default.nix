{
  config,
  inputs,
  self,
  inputs',
  self',
  ...
}: let
  user =
    if (config.modules.system.username == null)
    then "isabel"
    else "${config.modules.system.username}";
in {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs self inputs' self';
    };
    users = {
      # home directory for the user
      ${user} = ../home/${user};
    };
  };
}
