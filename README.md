# Simple Backup Solutions
A bundle of scripts, that contain few simple solutions for backup, which I'm using within my Ubuntu installations. 

## Incremental backup using Rsync

- This solution perfectly fits to my 'desktop' computers, where I want easy access to my backup files.

- It is [based on this nice answer][1], provided by [PerlDuck][2] on Ask Ubuntu SE, where are provided detailed explanations.

- There are two files:

  - `incremental_backup` - this is the main (`bash`) script. I would place it in `/usr/local/bin` to be accessible as shell command system wide.
 
  - `incremental_backup_cron` - this a (`sh`) script desingned to be placed in `/etc/cron.(daily|hourly|weekly)/`.

- Installation on fly (without using git):



 [1]: https://askubuntu.com/a/1029653/566421
 [2]: https://askubuntu.com/users/504066/perlduck
