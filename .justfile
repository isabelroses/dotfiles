default:
  @just --list --unsorted

[macos]
rebuild *args: verify
  darwin-rebuild switch --flake . {{args}} |& nom

[linux]
rebuild *args: verify
  sudo nixos-rebuild switch --flake . {{args}} |& nom

build pkg:
  nix build .#{{pkg}} --log-format internal-json -v |& nom --json

iso image: (build "images.{{image}} -o {{image}}")

[private]
verify *args:
  nix-store --verify {{args}}

repair: (verify "--check-contents --repair")

clean:
  @sudo true
  nix-collect-garbage --delete-older-than 3d
  nix store optimise

check:
  nix flake check

update *input:
  nix flake update {{input}} --refresh
