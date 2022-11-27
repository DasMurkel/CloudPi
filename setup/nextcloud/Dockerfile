FROM nextcloud:25.0.1
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    smbclient libsmbclient-dev libmagickcore-6.q16-6-extra ffmpeg libbz2-dev
RUN pecl install smbclient
RUN docker-php-ext-install bz2
RUN docker-php-ext-enable smbclient
