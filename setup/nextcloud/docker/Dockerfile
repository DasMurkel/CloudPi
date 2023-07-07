FROM nextcloud:26.0.3
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        smbclient libsmbclient-dev libmagickcore-6.q16-6-extra ffmpeg libbz2-dev \
    && pecl install smbclient \
    && docker-php-ext-install bz2 \
    && docker-php-ext-enable smbclient
