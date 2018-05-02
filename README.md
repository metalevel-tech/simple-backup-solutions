# Simple Backup Solutions

A bundle of scripts, that contain few simple solutions for backup, which I'm using within my Ubuntu installations.

## Incremental backup using Rsync

- This solution perfectly fits to 'desktop' systems, when you want easy access to your backup files and their history.

- It is [based on this nice answer][1], provided by [PerlDuck][2] on Ask Ubuntu SE, where are provided detailed explanations.

- There are two files:

  - [**`incremental_backup`**][3] - this is the main (`bash`) script. I would place it in `/usr/local/bin` to be accessible as shell command system wide.

  - [`incremental_backup_cron`][4] - this a (`sh`) script desingned to be placed in `/etc/cron.{daily,hourly,weekly}/`.

- Installation on fly (without using git):

  ````shell
  sudo wget -O /usr/local/bin/incremental_backup https://raw.githubusercontent.com/pa4080/simple-backup-solutions/master/incremental_backup
  sudo chmod +x /usr/local/bin/incremental_backup

  sudo wget -O /etc/cron.daily/incremental_backup_cron https://raw.githubusercontent.com/pa4080/simple-backup-solutions/master/incremental_backup_cron
  sudo chmod +x /etc/cron.daily/incremental_backup_cron
  ````

## Portable backup using Tar and 7zip

- This solution perfectly fits to 'server' systems, when you want small and portable backups.

- It is [based on this answer of mine][5] on Ask Ubuntu SE, where are provided detailed explanations.

- There are two files:

  - [**`portable_backup`**][6] - this is the main (`bash`) script. I would place it in `/usr/local/bin` to be accessible as shell command system wide.

  - [`portable_backup_cron`][7] - this a (`sh`) script desingned to be placed in `/etc/cron.{daily,hourly,weekly}/`.

- Installation on fly (without using git):

  ````shell
  sudo wget -O /usr/local/bin/portable_backup https://raw.githubusercontent.com/pa4080/simple-backup-solutions/master/portable_backup
  sudo chmod +x /usr/local/bin/portable_backup

  sudo wget -O /etc/cron.daily/portable_backup_cron https://raw.githubusercontent.com/pa4080/simple-backup-solutions/master/portable_backup_cron
  sudo chmod +x /etc/cron.daily/portable_backup_cron
  ````

## Notes

- [How to rsync multiple source folders - on Unix & Linux](https://unix.stackexchange.com/a/368216/201297)
- [Make "rm" move files to trash instead of completely removing them - on WEB UPD8](http://www.webupd8.org/2010/02/make-rm-move-files-to-trash-instead-of.html)
- [Command to move a file to Trash via Terminal - on Ask Ubuntu](https://askubuntu.com/q/213533/566421)
- [How to compare two dates in a shell - on Unix & Linux](https://unix.stackexchange.com/q/84381/201297)
- [**Exhaustive list of backup solutions for Linux** - on GitHub](https://github.com/sstark/others)

 [1]: https://askubuntu.com/a/1029653/566421
 [2]: https://askubuntu.com/users/504066/perlduck
 [3]: https://github.com/pa4080/simple-backup-solutions/blob/master/incremental_backup
 [4]: https://github.com/pa4080/simple-backup-solutions/blob/master/incremental_backup_cron
 [5]: https://askubuntu.com/a/1010102/566421
 [6]: https://github.com/pa4080/simple-backup-solutions/blob/master/portable_backup
 [7]: https://github.com/pa4080/simple-backup-solutions/blob/master/portable_backup_cron