# Running multiple minio servers under runsvdir

## Links
* https://kula.tproa.net/lnt/computers/backups/restic-systems-backups/pt2.html

## Rough background
A `backups` user has a home directory `/backups` and is responsible for
all server-side backup operations. `/backups/systems` is where system-level
backups live. Top-level conf exists as `/backups/systems/conf` and each
system being backed up lives at, e.g. `/backups/systems/ahost.example.com`.

Each of these 'system' directories has the following sub-directories:
* `logs`: logs from minio go into here
* `minio`: The root of the [minio](https://minio.io/) storage
* `conf`: configuration:
** `runsv`: the [runit](http://smarden.org/runit/) `runsv` directory
            that runs the `minio` server
** `minio`: configuration for this system's minio server, contains the
	    `config.json` and `certs` directory for minio

We run one instance of minio for each system being backed up. The 
individual `runsv` directories that are responsible for running and
handling logging for each `minio` server are then symlinked under the
`/backups/systems/conf/runit` directory, which is handled by
`runsvdir`

## Files
* `backup-minio.service`: a systemd service unit file for the `runsvdir`
  that runs all of the minio servers.
