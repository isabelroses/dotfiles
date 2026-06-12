---
title: Restoring from a backup
description: Recover service data from the Borg backups stored on rsync.net.
---

All persistent service data is backed up nightly with
[BorgBackup](https://www.borgbackup.org/) to rsync.net.

## How the Backups Are Laid Out

- **One repository per service**. e.g. `postgresql`, `forgejo`, `vaultwarden`,
  and so on.
- **Archive names** follow `<host>-<service>-<timestamp>`, e.g.
  `<host>-postgresql-2026-06-06T02:30:00`.
- **Encryption** is `repokey-blake2`. Each repo's passphrase is a stored via
  sops-nix.
- As mentioned before I use rsync.net, it runs **Borg 1.4**, so every command
  needs `--remote-path=borg14`.
- Jobs run daily at 02:30 with grandfather-father-son retention (7 daily, 4
  weekly, 3 monthly).

The secrets are readable only by root, so run everything below as root on the
host that owns the data.

## Restoring Files

Borg stores paths **without the leading `/`**. Extract from `/` as root so
ownership and permissions are preserved exactly:

```bash
cd /
borg --remote-path=borg14 extract --progress \
  "::<archive>" \
  path/under/root
```

Preview first without writing anything:

```bash
borg --remote-path=borg14 extract --dry-run --list "::<archive>" path/under/root
```

:::caution[Check free space first]
`extract` writes the full **uncompressed** size. Confirm the target filesystem
has room with `df -h` before starting. A failed extract on a full disk can take
other services down with it.
:::

## PostgreSQL

The job backs up the data directory (`<postgres-datadir>`).
Restore it with the service stopped, then let Postgres recover:

```bash
systemctl stop postgresql

cd /
SERVICE=postgresql
export BORG_REPO="<account>@<host>.rsync.net:$SERVICE"
export BORG_RSH="ssh -i /run/secrets/borg-sshkey"
export BORG_PASSCOMMAND="cat /run/secrets/borg-$SERVICE-pass"

borg --remote-path=borg14 extract --progress \
  "::<host>-postgresql-<timestamp>" <postgres-datadir>

# remove a stale path
rm -f <postgres-datadir>/postmaster.pid

systemctl reset-failed postgresql
systemctl start postgresql
```

Because this is a hot filesystem snapshot, Postgres replays its WAL (crash
recovery) on start. Confirm it finished and the data is there:

```bash
runuser -u postgres -- psql -c 'SELECT pg_is_in_recovery();'   # expect: f
runuser -u postgres -- psql -c '\l'                            # list databases
```

### Matrix Synapse

A hot Postgres backup restores table data via WAL replay, but an application's
own bookkeeping table can end up *ahead* of the restored sequences. Synapse
detects this and refuses to start:

```
IncorrectDatabaseSetup: Postgres sequence 'events_stream_seq' is inconsistent
with associated stream position of 'events' in the 'stream_positions' table.
```

Synapse suggests deleting the `stream_positions` row, which is safe **only if the
sequence is not behind the real table** (otherwise you risk duplicate IDs).
Verify, then delete the stale rows so Synapse recomputes them on startup:

```sql
-- with synapse stopped, in the matrix-synapse database:
-- for each failing stream, confirm the sequence's last_value is >= the table max
SELECT (SELECT last_value FROM events_stream_seq)            AS seq,
       (SELECT max(stream_ordering) FROM events)            AS table_max,
       (SELECT max(stream_id) FROM stream_positions
          WHERE stream_name = 'events')                     AS stream_pos;

-- once confirmed (seq >= table_max), drop the stale positions:
DELETE FROM stream_positions
  WHERE stream_name IN ('events', 'presence_stream', 'receipts');
```

The affected streams are usually `events`, `presence_stream`, and `receipts`.
Restart Synapse afterward.

### Tranquil

[Read the upstream guide.](https://tangled.org/tranquil.farm/tranquil-pds/blob/main/docs/3_DEBUGGING_YOUR_SETUP.md#seq-from-pds-is-behind-seq-stored-by-relays)
