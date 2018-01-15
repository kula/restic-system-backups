# Setting up a backup server

## Links
* https://kula.tproa.net/lnt/computers/backups/restic-systems-backups/

## Background
A `backups` user has a home directory `/backups` and is responsible for
all server-side backup operations. `/backups/systems` is where system-level
backups live. Top-level conf exists as `/backups/systems/conf` and each
system being backed up lives at, e.g. `/backups/systems/ahost.example.com`.

A different directory layout is possible, but you will likely have to modify
scripts to match.

Each system being backed up has a collection of services which are responsible
for handling that system's backups. Currently there are two services: the
minio server that stores the restic backup objects, and `backup-syncd`, which
watches for new snapshots and runs a script to sychronize files to other
storage backends.

Each 'system' directory has the following sub-directories:
* `logs`: logs from the various services go here
* `minio`: The root of the [minio](https://minio.io/) storage
* `conf`: configuration:
  * `runsvs`: the [runit](http://smarden.org/runit/) `runsv` directories
   for the individual services
  * `minio`: configuration for this system's minio server, contains the
   `config.json` and `certs` directory for minio
  * `runsvdir`: a runsv formated service directory, which runs runsvdir
   to run everything under `runsvs`
  * `replica_sync`: a script called by `backup-syncd` when new snapshots
   are detected
  * `backup-syncd.log.conf`: a Python logging configuration file, defaults
   to something which logs to stdout, to work with svlogd in the runit
   suite

In general, everything logs under `logs`, using `svlogd`. 

## Files
* `backup-minio.service`: a systemd service unit file for the `runsvdir`
  that runs all of the minio servers. Where you put this is a matter of
  how systemd is configured on your system.
* `new-restic-server`: a convience script which will create the per-system
  configuration using the layout above.

## Adding a client

### Minio TLS certificates

This setup assumes you have a valid TLS certificate and key that client
systems will accept for the name of the backup server, located in
`/backup/systems/conf/public.crt` and `/backups/systems/conf/private.key`
respectively. It also assumes that you will use the same name to access
the backup server for all hosts which connect to it. If that isn't true,
you will want to make sure that the `public.crt` and `private.key`
located at `/backups/systems/aserver.example.com/conf/` are the correct
files or are symlinks to the correct file.

The creation of this certificate is beyond the scope of this document.

### Adding

* Pick a port for the minio server to run on. This must be unique per
  server being backed up and you must configure any firewalls to allow
  traffic from the client to reach this port on the server.
* `new-restic-server -H aserver.example.com -p <portno>`
* Edit `/backups/systems/aserver.examnple.com/conf/replica_sync` as necessary
* `ln -s /backups/systems/aserver.example.com/conf/runsvdir /backups/systems/conf/runit/aserver.example.com`

On the client server you can now back up to this newly running minio server
on the port selected above, using the credentials in
`/backups/systems/aserver.example.com/conf/minio/config.json`
