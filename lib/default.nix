{
  nixpkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  self = inputs.self;
in
  nixpkgs.lib.extend (
    final: prev: {
      # filter files that have the .nix suffix
      filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

      # import files that are selected by filterNixFiles
      importNixFiles = path:
        (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
            (filterAttrs filterNixFiles (builtins.readDir path))))
        import;

      # a function that will append a list of groups if they exist in config.users.groups
      ifTheyExist = config: groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

      # a function that returns a boolean based on whether or not the groups exist
      ifGroupsExist = config: groups: lib.any (group: builtins.hasAttr group config.users.groups) groups;

      # return an int (1/0) based on boolean value
      boolToNum = bool:
        if bool
        then 1
        else 0;

      # make a service that is a part of the graphical session target
      mkGraphicalService = lib.recursiveUpdate {
        Unit.PartOf = ["graphical-session.target"];
        Unit.After = ["graphical-session.target"];
        Install.WantedBy = ["graphical-session.target"];
      };

      # just an alias to nixpkgs.lib.nixosSystem, lets me avoid adding
      # nixpkgs to the scope in the file it is used in
      mkSystem = nixpkgs.lib.nixosSystem;

      mkNixosSystem = {
        modules,
        system,
        ...
      } @ args:
        mkSystem {
          inherit modules system;
          specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
        };

      # mkIso is should be a set that extends mkSystem with necessary modules
      # to create an iso image

      mkNixosIso = {
        modules,
        system,
        ...
      } @ args:
        mkSystem {
          inherit system;
          specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
          modules =
            [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ]
            ++ args.modules or [];
        };
    }
  )
