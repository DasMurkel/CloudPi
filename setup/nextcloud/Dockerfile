FROM nextcloud
RUN apt update
RUN apt -y install smbclient libsmbclient-dev
RUN pecl install smbclient
RUN docker-php-ext-enable smbclient