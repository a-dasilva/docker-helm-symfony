#!/bin/sh
set -e

if [ "$1" = 'fpm' ] || [ "$1" = 'supervisor' ]; then
  mkdir -p /app/var/cache /app/var/log
  setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX /app/var
  setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX /app/var

  if [ "$APP_ENV" = 'dev' && "$1" = 'fpm' ]; then
    # Install composer package & run migrate on dev env. It should run once on `fpm` or `supervisor` service.

		composer install --prefer-dist --no-progress --no-suggest --no-interaction

    echo "Waiting for db to be ready..."

    until bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
      sleep 1
    done

    if ls -A src/Migrations/*.php > /dev/null 2>&1; then
      bin/console doctrine:migrations:migrate --no-interaction
    fi
	fi

	if [ "$1" = 'supervisor' ]; then
	  cp /var/supervisord/base.conf /var/supervisord/supervisord.conf

    { \
      echo '[inet_http_server]'; \
      echo 'port = *:9000'; \
      echo "username = ${SUPERVISORD_USERNAME:-root}"; \
      echo "password = ${SUPERVISORD_PASSWORD:-root}"; \
    } >> /var/supervisord/supervisord.conf

    set -- supervisord -c /var/supervisord/supervisord.conf

    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX /var/supervisord
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX /var/supervisord
  elif [ "$1" = 'fpm' ]; then
    set -- php-fpm
	fi

fi

exec docker-php-entrypoint "$@"