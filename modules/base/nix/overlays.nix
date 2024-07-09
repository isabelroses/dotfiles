{
  self,
  inputs,
  inputs',
  ...
}:
{
  nixpkgs.overlays = [
    self.overlays.default
    inputs.rust-overlay.overlays.default

    (_: _: {
      lix = inputs'.lix.packages.default.overrideAttrs (oldAttrs: {
        # I've upstreamed this, waiting for merge
        patches = [ ./patches/0001-show-description.patch ];

        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            ln -s $out/bin/nix $out/bin/lix
          '';
      });
    })

  ];
}
