{
  lib,
  pkgs,

  inputs,
  self ? inputs.self,

  nixosOptionsDoc,
  runCommand,
  linkFarm,
}:
let
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.modules) evalModules;
  inherit (lib.strings) removePrefix;

  # hoist to prevent recomputation
  selfStr = toString self;

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
      ]
      ++ extraModules;

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
              let
                declStr = toString decl;
              in
              if lib.hasPrefix selfStr declStr then
                gitHubDeclaration "isabelroses" "dotfiles" (removePrefix "/" (removePrefix selfStr declStr))
              else
                decl
            ) opt.declarations;
          };
      };
    in
    runCommand "${name}-module-doc.md" { } ''
      cat >$out <<EOF
      ---
      title: ${name}
      ---
      EOF

      cat ${doc.optionsCommonMark} >> $out
    '';

  nixosEval = mkEval "nixos" [ ];
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
