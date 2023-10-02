{clangStdenv}:
clangStdenv.mkDerivation {
  pname = "sample-c-cpp";
  version = "0.0.1";

  src = ./.;

  makeFlags = ["PREFIX=$(out)"];
}
