# CloudPi
Setup files and documentation for my RaspberryPi 4 based NAS/Cloud with _DietPi_, _OpenMediaVault_, _Docker_, _Traefik_ and _Nextcloud_ available over IPv4 and IPv6.


## Introduction
The goal of this project is to simplify the installation of _OpenMediaVault_ and _Nextcloud_ on a RaspberryPi, even though it can probably be applied to other Single Board Computers as well. 
To try and eliminate some of the errors that happened during the creation of this project, as many things as possible are automated.

As underlying linux system, _DietPi_ is used to reduce unnecessary overhead as much as possible.
Nextcloud will be running in a _Docker_ container.
_Traefik_ will be used as easy to use and configure Revese Proxy to allow https connections with _Lets Encrypt_.
The entire setup will be accessible not just over IPv4 but also IPv6 which caused some headaches.
Of course, a dyndns service (or a fixed IP and a domain) are necessary to access the service from the internet.


## Install _DietPi_

_DietPi_ is a highly optimized linux system, stripped down to the bare minimum.
It is customized to the RaspberryPi but there are also builds for other SBCs.
It should be downloaded from https://dietpi.com and installed according to the guide on the _DetPi_ site.

At the first login with user `root` and PW `dietpi`.
The system will install a couple of things.


## Configure DietPi
* Performance Options
  * Temp-Limit -> 65°C
  * Idle Frequency -> 300Mhz (It's going to be in idle a lot of the time after all)
* Advanced Options
  * Time Sync Mode -> Custom (Necessary because OMV will bring its own timesync method)
* Language/Regional Options
  * Timezone -> Your timezone
* Security Options
  * Change Hostname (This should be the last step because it recommends a reboot)

Reboot

* Replace Dropbear with OpenSSH. This is necessary because OMV requires OpenSSH and replacing Dropbear during OMV installation causes the installation to fail.

As an alternative, it's possible to make some of these adaptations in the `dietpi.txt` before the first boot of the system.

## Copy setup script
Using the provided setup script and files a lot of the setup process can be automated from this point on.
Copy or git-clone this repository to `/root/` for the rest of the instructions.

## OpenMediaVault
### Installation
For the installation of OpenMediaVault, simply run `setup.sh installOMV`. It will download and execute the OMV installation script that will run for quite some time.

### First login
User: admin
PW: openmediavault


### Settings in OMV
* Set Port to 8081
* Change Web-Admin-PW
* Enable system surveillance
* Install Docker
* [Install Portainer]
* Enable IPv6
* Setup Drive
* Setup Home Share
* Setup user
* Enable Home directories
  * In Settings for Users
  * In Settings for SMB/CIFS



## Open Ports in Router/Firewall and configure Dynamic DNS service
### Firewall
In order for the setup to be accessible from the internet, ports
* 80 (http)
* 443 (https)
need to be opened in the router firewall.
In the case of IPv4, this requres NAT-forwarding.
In case of IPv6, the router must ensure that the device in the local LAN will get a public IPv6 address.
In the popular Fritz.Box routers by AVM, that means that _DNS-Server, Präfix (IA_PD) und IPv6-Adresse (IA_NA) zuweisen_ must be configures in the IPv6 settings.

### Dynamic DNS
It is crucial that the deivce also is available under a domain-name, not just an IP-Addres.
This is necessary for the Lets Encrypt service which uses the domain-name for its certificate.
Therefore, select the Danamic DNS service of choice.

If _dynv6.net_ is used, the service provides a script that will update the services IP.
It's in the download-section and must be called periodically to keep the domains A/AAAA record up-to-date.
Please check the scripts instructions on how to set it up.
A cron-job should be put into place to run it.
Run `crontab -e` to set it up using your favorite editor.

    # m h  dom mon dow   command
    */10 * *   *   *     /root/dynv6.sh
    @reboot              /root/dynv6.sh


As a check, you can now try pinging the device over the domain name:

```sh
ping -4 DOMAIN_NAME
ping -6 DOMAIN_NAME
 ```

It should at least resolve the domain name correctly.
With IPv4, it can only ping the local router (provided NAT is used), with IPv6, the server will be pinged.

## Running the configuration script
Run
```sh
setup.sh postOMV
```
It will query some information necessary to run the services.
The script can not be re-run.
It modifies the docker-compose files with the provided data.
In case it needs to be run again, the files must be reverted to their original state.

## Starting Traefik
With the device available from the internet, the reverse proxy traefik an be started and take care of creating the Let's Encrypt certificate.
 
 ```sh
cd traefik
docker-compose up -d
```

After the containers have started, the status of traefik can be checked from within the local network under its web interface: `LOCAL_HOSTNAME:8080`

Also, the whoami service should be available under `http[s]://YOUR_DNS_NAME/whoami`
The connection should also be encrypted.

**Remark:** It can take a couple of minutes for the https certificate to be created.

## Starting Nextcloud
With proxy and encrypted communication up and running, the next and final step is to start Nextcloud.
```sh
cd nextcloud
docker-compose up -d
```

This will pull the docker containers for the _MariaDB_ and _Nextcloud_.
There is also a dockerfile included which installs and enables the smbclient extension in the docker image.
This is useful for mounting network drives provided by OpenMediaVault (or other local _cifs_ shares).

Once docker did its magic, browse to `https://YOUR_DNS_NAME` and it should show the Login Page for the first Nextcloud login.


## Sources
This setup was created using the following articles as references. I want to thank the authors!

* https://dbtechreviews.com/2019/12/how-to-install-openmediavault-on-raspberry-pi-4/
* https://dbtechreviews.com/2020/03/how-to-install-nextcloud-on-openmedivault-5-with-remote-access-and-ssl/
* https://goneuland.de/traefik-v2-reverse-proxy-fuer-docker-unter-debian-10-einrichten/#5_TLS_Sicherheit_verbessern
* https://goneuland.de/nextcloud-server-mit-docker-compose-und-traefik-installieren/
* https://www.ssllabs.com/ssltest/

