{
  python3,
  callPackage,
  mkShellNoCC,
  ...
}: let
  defaultPackage = callPackage ./default.nix;
in
  mkShellNoCC {
    packages = [
      (python3.withPackages defaultPackage.propagatedBuildInputs)
    ];
  }
