{ inputs', ... }:
{
  garden.packages = {
    inherit (inputs'.izvim.packages) izvim;
  };
}
