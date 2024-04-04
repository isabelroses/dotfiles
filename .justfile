default:
  @just --list --unsorted

[macos]
rebuild: verify
  darwin-rebuild switch --flake . |& nom

[linux]
rebuild: verify
  @sudo true
  nixos-rebuild switch --flake . |& nom

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
  nix flake lock --update-input {{input}}

update-all:
  nix flake update
