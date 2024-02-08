{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;
  #
  # mkNixosSystem wraps mkSystem with flake-parts' withSystem to give us inputs' and self' from flake-parts
  # which can also be used as a template for nixos hosts with system type and modules to be imported with ease
  # specialArgs is also defined here to avoid defining them for each host
  mkNixSystem = {
    host,
    modules,
    system,
    withSystem,
    ...
  } @ args:
    withSystem system ({
      inputs',
      self',
      ...
    }: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      ldTernary = l: d:
        if pkgs.stdenv.isLinux
        then l
        else if pkgs.stdenv.isDarwin
        then d
        else throw "Unsupported system";
      mkSystem = with inputs; ldTernary nixpkgs.lib.nixosSystem darwin.lib.darwinSystem;

      target = ldTernary "nixosConfigurations" "darwinConfigurations";
      mod = ldTernary "nixosModules" "darwinModules";

      hm = inputs.home-manager.${mod}.home-manager;
    in {
      ${target}.${args.host} = mkSystem {
        inherit system;
        modules =
          [
            hm
            "${self}/hosts/${host}"
            {config.modules.system.hostname = host;}
          ]
          ++ args.modules or [];
        specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
      };
    });

  # mkIso is should be a set that extends mkSystem (again) with necessary modules to create an Iso image
  # don't use mkNixSystem as it is complelty overkill for an iso and will have too much data, we need a light weight image
  mkNixosIso = {
    host,
    system,
    ...
  } @ args: {
    nixosConfigurations.${args.host} = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
      modules =
        [
          # get an installer profile from nixpkgs to base the Isos off of
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          "${self}/hosts/${host}"
        ]
        ++ args.modules or [];
    };
  };

  mkSystems = systems: lib.mkMerge (map mkNixSystem systems);

  mkNixosIsos = systems: lib.mkMerge (map mkNixosIso systems);
in {
  inherit mkSystems mkNixSystem mkNixosIsos mkNixosIso;
}
