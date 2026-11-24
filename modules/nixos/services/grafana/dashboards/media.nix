{ d }:
let
  inherit (d)
    q
    rate
    increase
    stat
    status
    timeseries
    heading
    ;
in
d.dashboard {
  uid = "media";
  title = "Media";
  variables = [ ];
  time = "now-24h";

  rows = [
    [
      (status {
        title = "Status";
        w = 12;
        targets = [
          (q "sonarr_system_status" "sonarr")
          (q "radarr_system_status" "radarr")
          (q "prowlarr_system_status" "prowlarr")
          (q "qbittorrent_instance_connection_status" "{{instance_name}}")
        ];
      })
      (stat {
        title = "Health issues";
        w = 6;
        targets = [
          (q ''sum({__name__=~"(sonarr|radarr|prowlarr)_system_health_issues"}) or vector(0)'' "issues")
        ];
        thresholds.orange = 1;
      })
      (stat {
        title = "Free space";
        w = 6;
        unit = "bytes";
        targets = [
          (q ''min by (path) ({__name__=~"(sonarr|radarr)_rootfolder_freespace_bytes"})'' "{{path}}")
        ];
      })
    ]

    [ (heading "Library") ]
    [
      (stat {
        title = "TV";
        w = 12;
        targets = [
          (q "sonarr_series_total" "series")
          (q "sonarr_episode_downloaded_total" "episodes")
          (q "sonarr_episode_missing_total" "missing")
          (q "sonarr_episode_cutoff_unmet_total" "upgradable")
        ];
      })
      (stat {
        title = "Movies";
        w = 12;
        targets = [
          (q "radarr_movie_total" "movies")
          (q "radarr_movie_downloaded_total" "downloaded")
          (q "radarr_movie_missing_total" "missing")
          (q "radarr_movie_cutoff_unmet_total" "upgradable")
        ];
      })
    ]
    [
      (timeseries {
        title = "Library size";
        unit = "bytes";
        stack = true;
        targets = [
          (q "sum(sonarr_series_filesize_bytes)" "tv")
          (q "radarr_movie_filesize_total" "movies")
        ];
      })
      (timeseries {
        title = "Arr queues";
        targets = [
          (q "sum(sonarr_queue_total)" "sonarr")
          (q "sum(radarr_queue_total)" "radarr")
        ];
      })
    ]

    [ (heading "qBittorrent") ]
    [
      (timeseries {
        title = "Transfer";
        w = 12;
        unit = "Bps";
        targets = [
          (q "sum(${rate "qbittorrent_session_download_bytes"})" "download")
          (q "sum(${rate "qbittorrent_session_upload_bytes"})" "upload")
        ];
      })
      (timeseries {
        title = "Torrents";
        w = 8;
        stack = true;
        targets = [
          (q "sum(qbittorrent_torrents_downloading)" "downloading")
          (q "sum(qbittorrent_torrents_seeding)" "seeding")
          (q "sum(qbittorrent_torrents_paused)" "paused")
          (q "sum(qbittorrent_torrents_checking)" "checking")
          (q "sum(qbittorrent_torrents_error)" "error")
        ];
      })
      (stat {
        title = "All-time ratio";
        w = 4;
        h = 8;
        unit = "none";
        targets = [
          (q "sum(qbittorrent_alltime_upload_bytes) / sum(qbittorrent_alltime_download_bytes)" "ratio")
        ];
      })
    ]
    [
      (timeseries {
        title = "Uploaded by tracker";
        w = 24;
        unit = "bytes";
        targets = [
          (q "topk(10, sum by (tracker_name) (qbittorrent_tracker_uploaded_bytes))" "{{tracker_name}}")
        ];
      })
    ]

    [ (heading "Prowlarr") ]
    [
      (stat {
        title = "Indexers";
        w = 4;
        h = 8;
        targets = [
          (q "prowlarr_indexer_enabled_total" "enabled")
          (q "sum(prowlarr_indexer_unavailable) or vector(0)" "unavailable")
        ];
      })
      (timeseries {
        title = "Queries";
        w = 10;
        targets = [
          (q "sum by (indexer) (${increase "prowlarr_indexer_queries_total"})" "{{indexer}}")
        ];
      })
      (timeseries {
        title = "Grabs";
        w = 10;
        targets = [
          (q "sum by (indexer) (${increase "prowlarr_indexer_grabs_total"})" "{{indexer}}")
        ];
      })
    ]
    [
      (timeseries {
        title = "Failed queries";
        unit = "short";
        targets = [
          (q "sum by (indexer) (${increase "prowlarr_indexer_failed_queries_total"})" "{{indexer}}")
        ];
      })
      (timeseries {
        title = "Response time";
        unit = "ms";
        targets = [ (q "prowlarr_indexer_average_response_time_ms" "{{indexer}}") ];
      })
    ]
  ];
}
