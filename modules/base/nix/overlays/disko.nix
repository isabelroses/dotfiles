_: prev: {
  disko = prev.cocogitto.overrideAttrs (oa: {
    postPatch =
      (oa.postPatch or "")
      + ''
        substituteInPlace disko \
          --replace-fail "(--extra-experimental-features flakes)" "(--extra-experimental-features 'flakes pipe-operator recursive-nix')"
        substituteInPlace disko-install \
          --replace-fail "--extra-experimental-features 'nix-command flakes'" "--extra-experimental-features 'nix-command flakes pipe-operator recursive-nix'"
      '';
  });
}
