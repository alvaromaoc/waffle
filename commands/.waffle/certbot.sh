wopenssl() {
  local days=$1
  local domain=$2

  local cert_path="/etc/letsencrypt/live/$domain"

  mkdir -p $cert_path

  openssl req -x509 -newkey rsa:2048 -keyout "$cert_path/privkey.pem" -out "$cert_path/fullchain.pem" -sha256 -days $days -nodes -subj "/CN=$domain"
  touch $cert_path/self-signed.txt

  chmod +r -R $cert_path/*

  /usr/local/bin/.waffle/logger.sh --level INFO "Generated self-signed certificate for $domain"
}

wcertbot() {
  local email=$1
  local server=$2
  local domain=$3

  certbot certonly \
    --webroot -w "/var/www/acme-challenge" \
    -d "$domain" \
    --email "$email" \
    --server "$server" \
    --agree-tos --non-interactive

  /usr/local/bin/.waffle/logger.sh --level INFO "Generated signed certificate for $domain"
}

remaining_days () {
  local certificate_file="$1"

  local threshold_days=30

  local expiration_date=$(openssl x509 -enddate -noout -in "$certificate_file" | awk -F '=' '{print $2}')
  local expiration_timestamp=$(date -d "$expiration_date" +%s)
  local current_timestamp=$(date +%s)

  local remaining_seconds=$((expiration_timestamp - current_timestamp))
  local remaining_days=$((remaining_seconds / 86400))
  
  echo $remaining_days
}

wrenew() {
  local server=$1

  /usr/local/bin/.waffle/logger.sh --level INFO "Started SSL certificates renewal"

  for domain in $(ls "/etc/letsencrypt/live")
  do
    if [ $(remaining_days "/etc/letsencrypt/live/$domain/fullchain.pem") -le 30 ]; then
      /usr/local/bin/.waffle/logger.sh --level INFO "Certificate for $domain is close to expire"
      if [ -f "/etc/letsencrypt/live/$domain/self-signed.txt" ]; then
        rm -f "/etc/letsencrypt/live/$domain/"*
        wopenssl 90 $domain
      else
        certbot renew --quiet --cert-name $domain --standalone --server ${server}
      fi

      if [ $? -ne 0 ]; then
        /usr/local/bin/.waffle/logger.sh --level ERROR "An error occurred while renewing SSL certificate for $domain"
      else
        /usr/local/bin/.waffle/logger.sh --level INFO "Certificate for $domain renewed successfully"
      fi
    else
      /usr/local/bin/.waffle/logger.sh --level INFO "Certificate for $domain is far to expire"
    fi
  done
}

usage() {
    echo "Usage: waffle sign [-s|--self] [-r|--renew] [-c|--certbot]"
}

while true; do
    case "$1" in
        -s|--self)      shift; wopenssl $@;;
        -r|--renew)     shift; wrenew $SERVER;;
        -c|--certbot)   shift; wcertbot $@;;
        "")             exit 0;;
        *)              usage; exit 1;;
    esac
done