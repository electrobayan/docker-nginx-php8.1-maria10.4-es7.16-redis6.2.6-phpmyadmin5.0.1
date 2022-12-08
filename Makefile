##################
# Variables
##################

DOCKER_COMPOSE = docker-compose -f ./docker-compose.yml --env-file ./.env
DOCKER_COMPOSE_PHP_FPM_EXEC = ${DOCKER_COMPOSE} exec -u www-data php-fpm

##################
# Docker compose
##################
dc_build:
	${DOCKER_COMPOSE} build

dc_start:
	${DOCKER_COMPOSE} start

dc_stop:
	${DOCKER_COMPOSE} stop

dc_up:
	${DOCKER_COMPOSE} up -d --remove-orphans

dc_ps:
	${DOCKER_COMPOSE} ps

dc_logs:
	${DOCKER_COMPOSE} logs -f

dc_down:
	${DOCKER_COMPOSE} down -v --rmi=all --remove-orphans

dc_restart:
	make dc_stop dc_start

##################
# App
##################

bash:
	${DOCKER_COMPOSE} exec -u www-data php bash

git_clone:
	${DOCKER_COMPOSE} exec -it php git clone ${r} /var/www/${p}

composer_i:
	${DOCKER_COMPOSE} exec -u www-data php composer install --working-dir=/var/www/${p}

composer_u:
	${DOCKER_COMPOSE} exec -u www-data php composer upgrade --working-dir=/var/www/${p}

rm_be_cache:
	${DOCKER_COMPOSE} exec -u www-data php rm -fr /var/www/${p}/var/cache rm -fr /var/www/${p}/generated/metadata rm -fr /var/www/${p}/generated/code rm -fr /var/www/${p}/var/view_preprocessed rm -fr /var/www/${p}/var/page_cache

rm_fe_cache:
	${DOCKER_COMPOSE} exec -u www-data php rm -fr /var/www/${p}/var/cache /var/www/${p}/var/view_preprocessed /var/www/${p}/var/page_cache /var/www/${p}/pub/static/frontend /var/www/${p}/pub/static/_cache

cache_flush:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento cache:flush

upgrade:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento setup:upgrade

reindex:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento indexer:reindex

image_resize:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento catalog:images:resize

s_dev:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento deploy:mode:set developer

s_prod:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento deploy:mode:set production

m_install:
	${DOCKER_COMPOSE} exec -u www-data php /var/www/${p}/bin/magento setup:install \
                                                   --base-url=http://${p}/ \
                                                   --db-host=${dbhost} \
                                                   --db-name=${db} \
                                                   --db-user=root \
                                                   --db-password=root \
                                                   --admin-firstname=admin \
                                                   --admin-lastname=admin \
                                                   --admin-email=test@test.com \
                                                   --admin-user=admin \
                                                   --admin-password=123123 \
                                                   --language=en_US \
                                                   --currency=USD \
                                                   --timezone=America/Chicago \
                                                   --use-rewrites=1 \
                                                   --elasticsearch-host=elasticsearch \
                                                   --backend-frontname=admin

##################
# Db
##################
db_import:
	${DOCKER_COMPOSE} exec -T ${c} mysql -uroot -proot ${db} < ${f}

db_export:
	${DOCKER_COMPOSE} exec -T ${c} mysqldump -uroot -proot ${db} | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip > ${db}.sql.gz