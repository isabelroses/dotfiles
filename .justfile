[private]
default:
  @just --list --unsorted

# rebuild the boot
boot *args: (builder "boot" args)

# test what happens when you switch
test *args: (builder "test" args)

# switch the new system configuration
switch *args: (builder "switch" args)

# build the package, you must specify the package you want to build
build pkg:
  nix build .#{{pkg}} --log-format internal-json -v |& nom --json

# build the iso image, you must specify the image you want to build
iso image: (build "images.{{image}} -o {{image}}")

[private]
verify *args:
  nix-store --verify {{args}}

# repairs the nix store from any breakages it may have
repair: (verify "--check-contents --repair")

# clean the nix store and optimise it
clean:
  @sudo true
  nix-collect-garbage --delete-older-than 3d
  nix store optimise

# check the flake for errors
check:
  nix flake check

# update the lock file, if inputs are provided, only update those, otherwise update all
update *input:
  nix flake update {{input}} --refresh

# setup our nixos and darwin builder
[private]
builder goal *args:
  nh os {{goal}} -- {{args}}

# we have this setup incase i ever want to go back and use the old stuff
[private]
[linux]
classic goal *args:
  sudo nixos-rebuild {{goal}} --flake . {{args}} |& nom
