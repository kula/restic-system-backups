# Client-side bits for restic system backups

## Handling `Unable to backup/restore files/dirs with same name`

For various historic reasons, I want to back up the following directories on my
servers:

* `/etc/`
* `/local`
* `/usr/local`
* `/var`

Unfortunately, with [Unable to backup/restore files/dirs with same name](https://github.com/restic/restic/issues/549), 
`/usr/local` and `/local` both get backed up as `local` at the top-level of your restic backup. Later versions will
rename one of those to be `local-0` or something like that, but it's really confusing. I'd like the full path of the
directories I'm backing up to be how they are identified in the repository. There's work to make it that way in 
restic 0.8, but until then the suggestion is to back up `/` and just exclude everything you don't want.

To help with that, I wrote `restic-unroll`, which does that dynamically &emdash; so I can add or
remove things to my `/etc/restic/include-files` file like I would normally and not have to worry about
'unrolling' those directories to get around this bug.

Side note: there's got to be a term for what I'm trying to do with directories, and I'm sure it isn't 'unrolling',
but that's what's stuck in my head thus far.

`daily-restic-backups` is a little wrapper that demonstrates its usage, and is suitable for a daily backup cron job.
