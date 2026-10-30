{ yt-dlp, nodejs }:
(yt-dlp.override {
  jsRuntime = nodejs;
}).overrideAttrs
  (prevAttrs: {
    makeWrapperArgs = prevAttrs.makeWrapperArgs or [ ] ++ [
      "--add-flag"
      "--js-runtimes=node"
    ];
  })
