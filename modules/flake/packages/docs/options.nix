{
  lib,
  pkgs,
  self,
  inputs,

  nixosOptionsDoc,
  runCommandNoCC,
  linkFarm,
}:
let
  inherit (lib)
    evalModules
    filterAttrs
    removePrefix
    ;

  gitHubDeclaration = user: repo: subpath: {
    url = "https://github.com/${user}/${repo}/blob/main/${subpath}";
    name = subpath;
  };

  mkEval =
    module: extraModules:
    evalModules {
      modules = [
        (self + /modules/${module})
        {
          _module = {
            check = false;
            args = { inherit pkgs; };
          };
        }
      ] ++ extraModules;

      specialArgs = {
        inherit self inputs;
      };
    };

  mkDoc =
    name: options:
    let
      doc = nixosOptionsDoc {
        options = filterAttrs (n: _: n != "_module") options;
        documentType = "none";
        transformOptions =
          opt:
          opt
          // {
            declarations = map (
              decl:
              if lib.hasPrefix (toString self) (toString decl) then
                gitHubDeclaration "isabelroses" "dotfiles" (
                  removePrefix "/" (removePrefix (toString self) (toString decl))
                )
              else
                decl
            ) opt.declarations;
          };
      };
    in
    runCommandNoCC "${name}-module-doc.md" { } ''
      cat >$out <<EOF
      # ${name}
      EOF

      cat ${doc.optionsCommonMark} >> $out
    '';

  nixosEval = mkEval "nixos" [ { mailserver.fqdn = "meow"; } ];
  darwinEval = mkEval "darwin" [ ];
  hmEval = mkEval "home" [
    {
      _module.args = {
        osConfig = nixosEval.config;
        osClass = "nixos";
      };
    }
  ];

  nixos = mkDoc "nixos" nixosEval.options.garden;
  darwin = mkDoc "darwin" darwinEval.options.garden;
  hm = mkDoc "home-manager" hmEval.options.garden;
in
linkFarm "modules" [
  {
    name = "index.md";
    path = runCommandNoCC "index.md" { } ''
      cat >$out <<EOF
      - [nixos](options/nixos.md)
      - [darwin](options/darwin.md)
      - [home-manager](options/home-manager.md)
      EOF
    '';
  }
  {
    name = "nixos.md";
    path = nixos;
  }
  {
    name = "darwin.md";
    path = darwin;
  }
  {
    name = "home-manager.md";
    path = hm;
  }
]
