{
  homeManagerModules = {
    version = 1;
    doc = "The `homeManagerModules` flake output defines Home-Manager modules exported by the flake.";
    inventory = output: let
      recurse = attrs: {
        children = (name: value:
          if builtins.isAttrs value
          then {
            # Tell `nix flake show` what this is.
            what = "exported home-manager module";
            # Make `nix flake check` enforce the camel case naming convention.
            evalChecks.camelCase = builtins.match "[a-z]+((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?" name == [];
          }
          else throw "unsupported 'homeManagerModules' type")
        attrs;
      };
    in
      recurse output;
  };
}
