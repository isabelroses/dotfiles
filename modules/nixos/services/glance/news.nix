{ glanceLib, ... }:
let
  inherit (glanceLib) mkPage;
in
mkPage "News" [
  {
    type = "markets";
    hide-title = true;
    markets = [
      {
        name = "Bitcoin";
        symbol = "BTC-GBP";
      }
      {
        name = "Ethereum";
        symbol = "ETH-GBP";
      }
      {
        name = "Monero";
        symbol = "XMR-GBP";
      }
    ];
  }
  {
    type = "rss";
    title = "News";
    style = "detailed-list";
    feeds = [
      {
        name = "Al Jazeera";
        url = "https://www.aljazeera.com/xml/rss/all.xml";
      }
      {
        name = "BBC News";
        url = "http://feeds.bbci.co.uk/news/rss.xml";
      }
      {
        name = "The Guardian";
        url = "https://www.theguardian.com/uk/rss";
      }
    ];
  }
]
