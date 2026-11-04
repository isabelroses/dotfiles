{ lib }:
let
  inherit (lib.types) str;
  inherit (lib.options) mkOption mkEnableOption;

  /**
    A quick way to use my services abstraction

    # Arguments

    - [name]: The name of the service
    - [port]: The default port, this defaults to 0 for services without one
    - [host]: The default bind address, this defaults to "127.0.0.1"
    - [domain]: The default domain, this defaults to ""

    # Type

    ```
    mkServiceOption :: String -> { port ? Int, host ? String, domain ? String } -> AttrSet
    ```
  */
  mkServiceOption =
    name:
    {
      port ? 0,
      host ? "127.0.0.1",
      domain ? "",
    }:
    {
      enable = mkEnableOption "Enable the ${name} service";

      host = mkOption {
        type = str;
        default = host;
        description = "The host for ${name} service";
      };

      port = mkOption {
        type = lib.types.port;
        default = port;
        description = "The port for ${name} service";
      };

      domain = mkOption {
        type = str;
        default = domain;
        defaultText = "networking.domain";
        description = "Domain name for the ${name} service";
      };
    };
in
{
  inherit mkServiceOption;
}
