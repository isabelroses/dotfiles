[private]
default:
  @just --list --unsorted

boot *args: (builder "boot" args)
test *args: (builder "test" args)
switch *args: (builder "switch" args)

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

# setup our nixos and darwin builder
[private]
[macos]
builder goal *args: verify
  darwin-rebuild {{goal}} --flake . {{args}} |& nom

[private]
[linux]
builder goal *args: verify
  nh os {{goal}} -- {{args}}

# we have this setup incase i ever want to go back and use the old stuff
[linux]
classic goal *args: verify
  sudo nixos-rebuild {{goal}} --flake . {{args}} |& nom
