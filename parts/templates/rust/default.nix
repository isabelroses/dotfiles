{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "sample-rust";
  version = "0.0.1";

  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
