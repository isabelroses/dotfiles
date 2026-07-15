# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code.
{ pkgs, inputs, ... }:
removeAttrs (pkgs.lib.makeScope pkgs.newScope (self: {
  inherit inputs;

  # keep-sorted start block=yes newline_separated=yes
  cmp-stats = self.callPackage ./cmp-stats/package.nix { };

  docs = self.callPackage ./docs/package.nix { };

  iztaller = self.callPackage ./iztaller/package.nix {
    nix = inputs.izlix.packages.${pkgs.stdenv.hostPlatform.system}.lix;
  };

  libdoc = self.callPackage ./docs/lib.nix { };

  optiondoc = self.callPackage ./docs/options.nix { };

  update-pins = self.callPackage ./update-pins/package.nix { };
  # keep-sorted end
})) [ "inputs" ]
