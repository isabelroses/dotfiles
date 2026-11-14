{ lib }:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.types) str;
  inherit (lib.options) mkOption mkEnableOption;

  /**
    A quick way to use my services abstraction

    Only the options a service is given a default for are declared, so every
    option that exists is one the service actually honours.

    # Arguments

    - [name]: The name of the service
    - [port]: The default port, leave it out for services that don't listen on one
    - [host]: The default bind address, this defaults to "127.0.0.1" for services
      with a port; pass null for services that can't be told where to bind
    - [domain]: The default domain, leave it out for services without one

    # Type

    ```
    mkServiceOption :: String -> { port ? Int, host ? String | Null, domain ? String } -> AttrSet
    ```
  */
  mkServiceOption =
    name:
    {
      port ? null,
      host ? "127.0.0.1",
      domain ? null,
    }:
    {
      enable = mkEnableOption "Enable the ${name} service";
    }
    // optionalAttrs (port != null && host != null) {
      host = mkOption {
        type = str;
        default = host;
        description = "The host for ${name} service";
      };
    }
    // optionalAttrs (port != null) {
      port = mkOption {
        type = lib.types.port;
        default = port;
        description = "The port for ${name} service";
      };
    }
    // optionalAttrs (domain != null) {
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
