let
  /**
    check if the host platform is linux and x86

    # Arguments

    - [pkgs] the package set

    # Type

    ```
    isx86Linux :: AttrSet -> Bool
    ```

    # Example

    ```nix
    isx86Linux pkgs
    => true
    ```
  */
  isx86Linux = pkgs: pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86;
in
{
  inherit isx86Linux;
}
