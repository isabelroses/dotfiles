{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    {
      formatter = config.treefmt.build.wrapper;

      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          shellcheck.enable = true;

          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };

          prettier = {
            enable = true;
            package = pkgs.prettierd;
            excludes = [ "*.age" ];
            settings = {
              editorconfig = true;
            };
          };

          shfmt = {
            enable = true;
            indent_size = 2;
          };
        };
      };
    };
}
