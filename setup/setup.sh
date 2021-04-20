#/bin/sh

if [ "$1" = "installOMV" ]
then
    wget https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install
    bash install
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
