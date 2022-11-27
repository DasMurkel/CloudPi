# How to upgrade Nextcloud docker

* First Shutdown `docker-compose down`
* Then Backup using borgbackup of OMV
* Then, adapt dockerfile for nextcloud Container and insert desired version in `FROM` line
* Make sure to get every major version - See Nextcloud upgrade guideline below
* Now, startup docker-compose again and force re-create: `docker-compose up --force-recreate --build -d`
* Check logs for errors (`docker-compose logs -f`)
* Check nextcloud settings for suggestions
* For MariaDB upgrade, check MariaDB upgrade guide. Important command: `docker exec CONTAINER_ID mariadb-upgrade -u root -p PASSWORD`


## Sources
* https://stackoverflow.com/a/49316987/1669328
* https://docs.nextcloud.com/server/latest/admin_manual/maintenance/upgrade.html
* https://mariadb.com/kb/en/upgrading/
