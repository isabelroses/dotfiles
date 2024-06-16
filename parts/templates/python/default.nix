{ lib, python3Packages, ... }:
python3Packages.buildPythonApplication {
  pname = "example-python";
  version = "0.0.1";

  src = ./.;

  # If you are using poetry, you can use the following configuration
  # pyproject = true;
  # build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [ ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  meta = {
    description = "A example python project using nix";
    homepage = "https://github.com/isabelroses/example-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
