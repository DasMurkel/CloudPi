#/bin/sh

if [ "$1" = "installOMV" ]
then
    # as taken from https://forum.openmediavault.org/index.php?thread/39490-install-omv6-on-debian-11-bullseye/
cat <<EOF >> /etc/apt/sources.list.d/openmediavault.list
deb http://packages.openmediavault.org/public shaitan main
# deb http://downloads.sourceforge.net/project/openmediavault/packages shaitan main
## Uncomment the following line to add software from the proposed repository.
# deb http://packages.openmediavault.org/public shaitan-proposed main
# deb http://downloads.sourceforge.net/project/openmediavault/packages shaitan-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb http://packages.openmediavault.org/public shaitan partner
# deb http://downloads.sourceforge.net/project/openmediavault/packages shaitan partner
EOF

export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get install --yes gnupg
wget --quiet --output-document=- https://packages.openmediavault.org/public/archive.key | gpg --dearmor | tee "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.gpg"
apt-get update
apt-get --yes --auto-remove --show-upgraded --allow-downgrades --allow-change-held-packages --no-install-recommends --option DPkg::Options::="--force-confdef" --option DPkg::Options::="--force-confold" install openmediavault-keyring openmediavault

# Populate the database.
omv-confdbadm populate

# Display the login information.
omv-salt deploy run hosts
cat /etc/issue

elif [ "$1" = "postOMV" ]
then
    docker || echo "Docker not yet installed. Please install docker" ; exit 1
    mkdir -p nextcloud/data nextcloud/db-config nextcloud/db-data
    read -p "Enter Hostname: " YOUR_HOSTNAME
    read -p "Enter E-Mail Address: " YOUR_MAIL_ADDRESS
    read -p "Enter MySQL Root-PW of choice: " YOUR_MYSQL_ROOT_PW
    read -p "Enter MySQL Nextcloud PW of coice: " YOUR_MYSQL_NEXTCLOUD_PW
    for file in traefik/docker-compose.yml nextcloud/docker-compose.yml
    do
        for ELEM in YOUR_HOSTNAME YOUR_MAIL_ADDRESS YOUR_MYSQL_ROOT_PW YOUR_MYSQL_NEXTCLOUD_PW
        do
            eval VALUE=\${$ELEM}
            sed -i s/${ELEM}/${VALUE}/g $file
        done
    done
    docker network create traefik
else
    echo "Please call with either 'installOMV' or 'postOMV' as parameter"
    exit 1
fi
