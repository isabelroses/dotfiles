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
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "old";
    extraSpecialArgs = {
      inherit inputs self inputs' self';
    };
    users = {
      # home directory for the user
      ${user} = ./${user};
    };
  };
}
