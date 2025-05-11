{
  lib,
  pkgs,
  self,
  config,
  osClass,
  ...
}:
let
  inherit (self.lib) mkProgram;

  progs = config.garden.programs;
  cfg = progs.${progs.defaults.shell};
  pkg = lib.getExe cfg.package;
in
{
  options.garden.programs = {
    bash = mkProgram pkgs "bash" {
      enable.default = true;
      package.default = pkgs.bashInteractive;
    };

    zsh = mkProgram pkgs "zsh" {
      enable.default = osClass == "darwin";
    };

    fish = mkProgram pkgs "fish" { };

    nushell = mkProgram pkgs "nushell" { };
  };

  # i hate special casing, i mean come on, i choose you noshell so I could
  # avoid special casing and yet here we are again special casing
  config = {
    xdg.configFile.shell =
      if progs.defaults.shell != "zsh" then
        {
          source = pkg;
        }
      else
        {
          executable = true;
          text = ''
            #!${pkg}

            if [[ -o interactive ]] ; then
              if [[ -o login ]] ; then
                exec ${pkg} --interactive --login "$@"
              fi

              exec ${pkg} --interactive "$@"
            fi

            if [[ -o login ]] ; then
              exec ${pkg} --login "$@"
            fi

            exec ${pkg} "$@"
          '';
        };
  };
}
