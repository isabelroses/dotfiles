# All credits to @nekowinston for this script
# modfied from https://github.com/nekowinston/nur/blob/49cfefd3c252f4c56725df01f817d1a8b93447d8/docs/default.nix
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce filterAttrs scrubDerivations removePrefix;

  mkEval = module:
    lib.evalModules {
      modules = [
        module
        {
          _module = {
            pkgs = mkForce (scrubDerivations "pkgs" pkgs);
            check = false;
          };
        }
      ];
      specialArgs = {inherit pkgs;};
    };

  mkDoc = name: options: let
    doc = pkgs.nixosOptionsDoc {
      options = filterAttrs (n: _: n != "_module") options;
      documentType = "none";
      transformOptions = opt:
        opt
        // {
          declarations =
            map
            (decl:
              if lib.hasPrefix (toString ../.) (toString decl)
              then let
                subpath = removePrefix "/" (removePrefix (toString ../.) (toString decl));
              in {
                url = "https://github.com/isabelroses/dotfiles/tree/main/${subpath}";
                name = subpath;
              }
              else decl)
            opt.declarations;
        };
    };
  in
    pkgs.runCommand "${name}-module-doc.md" {} ''
      cat >$out <<EOF
      # ${name} module options
      EOF

      cat ${doc.optionsCommonMark} >> $out
    '';

  convert = md:
    pkgs.runCommand "isabelroses-dotfiles.html" {nativeBuildInputs = with pkgs; [pandoc texinfo];} ''
      mkdir $out
      cp ${./pandoc.css} style.css
      pandoc -o file.texi ${builtins.concatStringsSep " " md}
      texi2any ./file.texi --html --split=chapter --css-include=./style.css --document-language=en -o $out
    '';

  modulesPath = ../modules;
  extraModulesPath = modulesPath + /extra;

  # internalEval = mkEval (import (modulesPath + /base));
  nixosEval = mkEval (import (extraModulesPath + /nixos));
  darwinEval = mkEval (import (extraModulesPath + /darwin));
  hmEval = mkEval (import (extraModulesPath + /home-manager));

  # internal = mkDoc "internal" internalEval.options.modules;
  nixos = mkDoc "nixos" nixosEval.options;
  darwin = mkDoc "darwin" darwinEval.options;
  hm = mkDoc "home-manager" hmEval.options;
in {
  html = convert [nixos darwin hm];
  md = pkgs.linkFarm "md" (lib.mapAttrsToList (name: path: {inherit name path;}) ["nixos" "darwin" "hm"]);
}
