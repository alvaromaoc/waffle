FROM ubuntu:jammy

EXPOSE 80 443

ARG WAFFLE_WORDPRESS_VERSION="6.2.2"

ENV WAFFLE_LETSENCRYPT_EMAIL=""
ENV WAFFLE_CERTBOT_SERVER="https://acme-v02.api.letsencrypt.org/directory"

# At 00:00 on Sunday - Weekly
ENV WAFFLE_CERTS_RENEW_CRON="0 0 * * 0"

# At minute 0 - Hourly
ENV WAFFLE_CHECK_CRON="* * * * *"

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN echo "UTC" > /etc/timezone

RUN apt update -y
RUN apt upgrade -y
RUN apt autoremove -y

RUN apt install -y nginx
RUN apt install -y php8.1-fpm php8.1-mysql
RUN apt install -y certbot openssl wget cron jq

COPY ./waffle /etc/waffle
COPY ./waffle/nginx.conf /etc/nginx/nginx.conf

RUN rm -f /etc/nginx/sites-enabled/default
RUN rm -f /etc/nginx/sites-available/default
RUN wget -O "/etc/waffle/wordpress.tar.gz" "https://wordpress.org/wordpress-${WAFFLE_WORDPRESS_VERSION}.tar.gz"

RUN mkdir -p /var/www/acme-challenge

COPY commands /usr/local/bin
RUN chmod 755 -R /usr/local/bin/*;

CMD ["/bin/sh", "-c", "waffle init"]