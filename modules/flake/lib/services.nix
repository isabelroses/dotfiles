{ lib }:
let
  inherit (lib.types) str;
  inherit (lib.options) mkOption mkEnableOption;

  /**
    A quick way to use my services abstraction

    Only the options a service is given a default for are declared, so every
    option that exists is one the service actually honours.

    # Arguments

    - [name]: The name of the service
    - [port]: The default port, leave it out for services that don't listen on one
    - [host]: The default bind address, "127.0.0.1" unless given; services
      without a port get none, and null leaves it out for services that can't
      be told where to bind
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
    }@args:
    let
      # only a service that listens on a port has an address to bind
      host' = if args ? port then host else null;
    in
    {
      enable = mkEnableOption "Enable the ${name} service";

      ${if host' != null then "host" else null} = mkOption {
        type = str;
        default = host';
        description = "The host for ${name} service";
      };

      ${if args ? port then "port" else null} = mkOption {
        type = lib.types.port;
        default = args.port;
        description = "The port for ${name} service";
      };

      ${if args ? domain then "domain" else null} = mkOption {
        type = str;
        default = args.domain or null;
        defaultText = "networking.domain";
        description = "Domain name for the ${name} service";
      };
    };
in
{
  inherit mkServiceOption;
}
