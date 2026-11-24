{ d }:
let
  inherit (d)
    q
    rate
    stat
    status
    timeseries
    heading
    ;

  dbs = ''datname!~"template.*"'';
in
d.dashboard {
  uid = "services";
  title = "Services";
  variables = [ ];

  rows = [
    [
      (status {
        title = "Scrape targets";
        w = 24;
        h = 6;
        targets = [ (q "up" "{{job}} · {{host}}") ];
      })
    ]

    [ (heading "PostgreSQL") ]
    [
      (timeseries {
        title = "Connections";
        w = 8;
        targets = [
          (q "sum by (host, datname) (pg_stat_database_numbackends{${dbs}})" "{{host}} {{datname}}")
        ];
      })
      (timeseries {
        title = "Transactions";
        w = 8;
        unit = "ops";
        targets = [
          (q "sum by (host) (${rate "pg_stat_database_xact_commit"} + ${rate "pg_stat_database_xact_rollback"})" "{{host}}")
        ];
      })
      (timeseries {
        title = "Cache hit ratio";
        w = 8;
        unit = "percent";
        targets = [
          (q "100 * sum by (host) (${rate "pg_stat_database_blks_hit"}) / (sum by (host) (${rate "pg_stat_database_blks_hit"}) + sum by (host) (${rate "pg_stat_database_blks_read"}))" "{{host}}")
        ];
      })
    ]
    [
      (timeseries {
        title = "Database size";
        w = 24;
        unit = "bytes";
        targets = [ (q "pg_database_size_bytes{${dbs}}" "{{host}} {{datname}}") ];
      })
    ]

    [ (heading "Nginx") ]
    [
      (timeseries {
        title = "Requests";
        unit = "reqps";
        targets = [ (q "sum by (host) (${rate "nginx_http_requests_total"})" "{{host}}") ];
      })
      (timeseries {
        title = "Connections";
        targets = [
          (q "nginx_connections_active" "{{host}} active")
          (q "nginx_connections_waiting" "{{host}} idle keepalive")
        ];
      })
    ]

    [ (heading "Matrix") ]
    [
      (timeseries {
        title = "Requests by method";
        w = 8;
        unit = "reqps";
        targets = [
          (q "sum by (method) (${rate "synapse_http_server_requests_received_total"})" "{{method}}")
        ];
      })
      (timeseries {
        title = "Federation received";
        w = 8;
        unit = "ops";
        targets = [
          (q "sum(${rate "synapse_federation_server_received_pdus_total"})" "events")
          (q "sum(${rate "synapse_federation_server_received_edus_total"})" "typing, receipts, presence")
        ];
      })
      (timeseries {
        title = "Memory";
        w = 8;
        unit = "bytes";
        targets = [ (q ''process_resident_memory_bytes{job="synapse"}'' "synapse") ];
      })
    ]

    [ (heading "Forgejo") ]
    [
      (stat {
        title = "Forge";
        w = 24;
        targets = [
          (q "gitea_users" "users")
          (q "gitea_repositories" "repos")
          (q "gitea_mirrors" "mirrors")
          (q "gitea_organizations" "orgs")
          (q "gitea_issues_open" "open issues")
          (q "gitea_stars" "stars")
        ];
      })
    ]
    [
      (timeseries {
        title = "Activity";
        w = 8;
        targets = [
          (q "delta(gitea_issues[1h])" "issues/h")
          (q "delta(gitea_comments[1h])" "comments/h")
          (q "delta(gitea_releases[1h])" "releases/h")
        ];
      })
      (timeseries {
        title = "Memory";
        w = 8;
        unit = "bytes";
        targets = [
          (q ''process_resident_memory_bytes{job="forgejo"}'' "resident")
          (q ''go_memstats_heap_inuse_bytes{job="forgejo"}'' "heap")
        ];
      })
      (timeseries {
        title = "Goroutines";
        w = 8;
        targets = [ (q ''go_goroutines{job="forgejo"}'' "goroutines") ];
      })
    ]

    [ (heading "Immich and Redis") ]
    [
      (stat {
        title = "Immich users";
        w = 4;
        h = 8;
        targets = [ (q "immich_users_total" "users") ];
      })
      (timeseries {
        title = "Redis";
        w = 20;
        targets = [
          (q "redis_connected_clients" "clients")
          (q "sum(${rate "redis_commands_processed_total"})" "commands/s")
          (q "sum(redis_db_keys)" "keys")
        ];
      })
    ]

    [ (heading "The monitoring itself") ]
    [
      (timeseries {
        title = "Prometheus series";
        w = 8;
        targets = [ (q "prometheus_tsdb_head_series" "series") ];
      })
      (timeseries {
        title = "Loki ingest";
        w = 8;
        unit = "Bps";
        targets = [ (q "sum(${rate "loki_distributor_bytes_received_total"})" "bytes") ];
      })
      (timeseries {
        title = "Scrape time";
        w = 8;
        unit = "s";
        targets = [ (q "max by (job) (scrape_duration_seconds)" "{{job}}") ];
      })
    ]
  ];
}
