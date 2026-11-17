# I would highly advise you do not use this repo as a dependency and instead you vendor this
# if you want to use this code.
{
  pkgs,
  inputs,
  self,
  root,
  ...
}:
removeAttrs
  (pkgs.lib.customisation.makeScope pkgs.newScope (scopeSelf: {
    inherit
      self
      inputs
      root
      ;

    # keep-sorted start block=yes newline_separated=yes
    cmp-stats = scopeSelf.callPackage ./cmp-stats/package.nix { };

    docs = scopeSelf.callPackage ./docs/package.nix { };

    gup = scopeSelf.callPackage ./gup/package.nix { };

    iztaller = scopeSelf.callPackage ./iztaller/package.nix {
      nix = inputs.izlix.lix;
    };

    libdoc = scopeSelf.callPackage ./docs/lib.nix { };

    mushroom-strategy = scopeSelf.callPackage ./mushroom-strategy/package.nix { };

    optiondoc = scopeSelf.callPackage ./docs/options.nix { };

    update-pins = scopeSelf.callPackage ./update-pins/package.nix { };

    # the scope's own yt-dlp would recurse, so take the nixpkgs one
    yt-dlp = scopeSelf.callPackage ./yt-dlp/package.nix { inherit (pkgs) yt-dlp; };
    # keep-sorted end
  }))
  [
    "self"
    "root"
    "inputs"
  ]
