{
  lib,
  python3Packages,
  doCheck ? false,
  ...
}:
python3Packages.buildPythonApplication {
  pname = "sample-python-project";
  version = "0.0.1";

  src = ./.;

  propagatedBuildInputs = with python3Packages; [ ];

  nativeCheckInputs = [ python3Packages.pytest ];

  checkPhase = lib.optionals doCheck ''
    runHook preCheck
    pytest
    runHook postCheck
  '';
}
