{
  extersia.cache.enable = true;

  # substituters to use
  nix.settings = {
    # don't worry that you cannot see cache.nixos.org here, it is added by default
    substituters = [
      "https://nix-community.cachix.org" # nix-community cache
      "https://isabelroses.cachix.org" # my cache
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="

      # the signing key used by our own machines, this lets us copy closures
      # between hosts without needing trusted-users on the target
      # <https://github.com/NixOS/nix/issues/2127>
      "amaterasu-1:N+SYn51iOvZps5JxxLwPSGUjVYHKf3MM6yMvDn3wkMI="
    ];
  };
}
