self: super: {
  discord = super.discord.overrideAttrs (
    _: { src = builtins.fetchTarball {
      url = "https://discord.com/api/download?platform=linux&format=tar.gz";
      sha256 = "04r1yx6aqd4f4lq7wfcgs3jfpn40gz7gwajzai1aqz12ny78rs7z";
    }; }
  );
}