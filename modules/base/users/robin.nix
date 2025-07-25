{ lib, config, ... }:
let
  inherit (lib) elem mkIf;
in
{
  config = mkIf (elem "robin" config.garden.system.users) {
    users.users.robin = {
      hashedPassword = "$y$j9T$fjikoYmPQxjKqjobJ/vZC/$ULBf6ns9PS8EUHBeRbnd3QQbOSCtAe18JhK3UUy.nv2";
    };
  };
}
