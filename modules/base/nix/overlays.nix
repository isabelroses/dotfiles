{ self, inputs, ... }:
{
  nixpkgs.config.overlays = [
    self.overlays.default
    inputs.beapkgs.overlays.default
    inputs.rust-overlay.overlays.default

    (final: prev: {
      openssh = prev.openssh.overrideAttrs (_: rec {
        version = "9.8p1";
        src = final.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
          hash = "sha256-3YvQAqN5tdSZ37BQ3R+pr4Ap6ARh9LtsUjxJlz9aOfM=";
        };
      });
    })
  ];
}
