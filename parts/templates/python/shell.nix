{
  callPackage,
  mkShellNoCC,
  python3,
  ...
}: let
  defaultPackage = callPackage ./default.nix;
in
  mkShellNoCC {
    packages = [
      (python3.withPackages defaultPackage.propagatedBuildInputs)
    ];
  }
