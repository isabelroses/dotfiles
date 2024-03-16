# modfied from https://github.com/nekowinston/nur/blob/49cfefd3c252f4c56725df01f817d1a8b93447d8/docs/default.nix
{
  lib,
  pkgs,
  self,
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

  gitHubDeclaration = user: repo: subpath: {
    url = "https://github.com/${user}/${repo}/blob/main/${subpath}";
    name = subpath;
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
              then gitHubDeclaration "isabelroses" "dotfiles" (removePrefix "/" (removePrefix (toString ../.) (toString decl)))
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

  pkgs-list = pkgs.runCommand "package-list.md" {} ''
    cat >$out <<EOF
    # package list
    EOF

    # declare all packages this flake provides
    cat ${self}/parts/pkgs/default.nix |
    awk '/= pkgs/{print $1}' |
    awk "!/docs/" |
    sed -E "s/(.*)/- [\1](https:\/\/github.com\/isabelroses\/dotfiles\/blob\/main\/flake\/pkgs\/\1\.nix)/g" >> $out

    # declare docs
    cat ${self}/parts/pkgs/default.nix |
    awk '/= docs/{print $1}' |
    sed -E "s/(.*)/- [\1](https:\/\/github.com\/isabelroses\/dotfiles\/blob\/main\/docs)/g" >> $out
  '';

  convert = md:
    pkgs.runCommand "isabelroses-dotfiles.html" {nativeBuildInputs = with pkgs; [pandoc texinfo];} ''
      mkdir $out

      pandoc \
        --from markdown \
        --to texinfo \
        -o file.texi \
        ${builtins.concatStringsSep " " md}

      sed -i "s/@top Top/@top isabelroses' modules/" file.texi

      texi2any ./file.texi \
        --html \
        --split=chapter \
        --css-include=${./pandoc.css} \
        --document-language=en \
        -o $out

      substituteInPlace $out/index.html --replace-quiet "Top (isabelroses&rsquo; modules)" "isabelroses&rsquo; modules"
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
  html = convert [pkgs-list nixos darwin hm];

  md = pkgs.linkFarm "md" [
    {
      name = "nixos";
      path = extraModulesPath + /nixos;
    }
    {
      name = "darwin";
      path = extraModulesPath + /darwin;
    }
    {
      name = "home-manager";
      path = extraModulesPath + /home-manager;
    }
  ];
}
