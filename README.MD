## Docker Image
Stack:
- Nginx
- PHP FPM 8.1
- Maria DB 10.4
- Elasticsearch 7.16.0
- Phpmyadmin 5.0.1

## Magento 2 supported versions:
- 2.4.4
- 2.4.4-p1
- 2.4.4-p2
- 2.4.5 (not verified)

## How to use

### Test run:
1) Install Docker and Docker compose
2) Clone the repository to your local machine
3) Prepare .env file. Just copy .env.dist file
4) Modify your hosts file by adding these two lines or your own:
```
127.0.0.1 hello.loc
127.0.0.1 phpmyadmin.loc
```
5) Run ``docker compose up -d`` from the root folder you just cloned
6) Go ``http://hello.loc/`` to see PHP info default page or ``http://phpmyadmin.loc`` to see phpmyadmin panel to wor with databases

### Create your domains:
7) Create your own hosts for further work based on ``./hosts/hello-loc.conf``. Just copy it, rename and modify and edit. Example:
```
server {
    index index.php;
    server_name my-new-project.loc;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/my-new-project.loc;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```
8) Don't forget to add your new domain ``my-new-project.loc`` to your computer **hosts** file
9) Go ``http://my-new-project.loc/`` to see your project

### Configure Magento:
10) Create ``auth.json`` file in the root of your magento project and make sure it is git ignored. Fill it with your Adobe account keys and with your github oath key. Any extra credentials for any 3-rd party extensions can be added as well. Example:
```
{
    "http-basic": {
        "repo.magento.com": {
            "username": "XXXXXXXX",
            "password": "XXXXXXXX"
        }
    },
    "github-oauth": {
        "github.com": "ghp_XXXXXXXXXXXXXXXXXXXXXXX"
    }
}
```

11) Create ``app/etc/env.php``. And fill it with the data needed (host name, db name, etc.). Example:
```
<?php
return [
    'backend' => [
        'frontName' => 'admin'
    ],
    'crypt' => [
        'key' => 'eb54762b26d8bf1b484c9b57ec914cf6'
    ],
    'db' => [
        'table_prefix' => '',
        'connection' => [
            'default' => [
                'host' => 'maria',
                'dbname' => 'test_db',
                'username' => 'root',
                'password' => 'root',
                'active' => '1',
                'driver_options' => [
                    1014 => false,
                    1001 => true
                ],
                'model' => 'mysql4',
                'engine' => 'innodb',
                'initStatements' => 'SET NAMES utf8;'
            ]
        ]
    ],
    'resource' => [
        'default_setup' => [
            'connection' => 'default'
        ]
    ],
    'x-frame-options' => 'SAMEORIGIN',
    'MAGE_MODE' => 'developer',
    'session' => [
        'save' => 'files'
    ],
    'cache' => [
        'frontend' => [
            'default' => [
                'id_prefix' => '40d_'
            ],
            'page_cache' => [
                'id_prefix' => '40d_'
            ]
        ]
    ],
    'lock' => [
        'provider' => 'db',
        'config' => [
            'prefix' => ''
        ]
    ],
    'cache_types' => [
        'config' => 1,
        'layout' => 1,
        'block_html' => 1,
        'collections' => 1,
        'reflection' => 1,
        'db_ddl' => 1,
        'compiled_config' => 1,
        'eav' => 1,
        'customer_notification' => 1,
        'config_integration' => 1,
        'config_integration_api' => 1,
        'full_page' => 1,
        'config_webservice' => 1,
        'translate' => 1,
        'vertex' => 1,
        'target_rule' => 1
    ],
    'downloadable_domains' => [
        'jpw-b2c.loc'
    ],
    'install' => [
        'date' => 'Fri, 07 Feb 2020 09:05:51 +0000'
    ],
    'queue' => [
        'consumers_wait_for_messages' => 1
    ],
    'cron' => [
        'enabled' => 0
    ],
    'directories' => [
        'document_root_is_pub' => true
    ]
];
```

12) Run composer install or other commands needed. See bash scripts bellow in the bonus section.

## Bonus
Use make scripts saved into ``Makefile`` to make your live easier :)
1) Install make ``sudo apt install make``
2) To use script just use it like that from your docker compose root directory where `p` is your project name folder in `www`: 
```
make composer_i p=hello.loc
```
Please, find the full list of command in the ``Makefile``

### ...or another option is to:
Add these bash scripts to your ``.bashrc`` files. Function name can be any you like.

Enter your PHP container via CLI. 
Please, note that your container name MUST contain ``php-`` in the grep part. 
```
enterServer(){
    docker exec -it $(docker ps --format "{{.Names}}" | grep "php-") bash
}
```

Stop all running containers:
``
stopAllContainers(){
    docker stop $(docker ps -q)
}
``

Run ``composer install`` for a particular project. 
Pass your project folder name as an argument. Example ``composerInstall hello.loc``
Please, note that your container name MUST contain ``php-`` in the grep part.
```
composerInstall(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") composer install --working-dir=/var/www/$1
}
```

Import the database where you should pass:
1) You MySQL/MariaDb container name
2) Your database name
3) Your dump path
```
importDb(){
    docker exec -i $1 mysql -uroot -proot $2 < $3
}
```

Export the database where you should pass:
1) You MySQL/MariaDb container name
2) Your database name
```
exportDb(){
    docker exec -i $1 mysqldump -uroot -proot $2 | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip > $2.sql.gz
}
```

### Magento 2 specific commands
Clear back-end cache.
Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name as an argument. Example ``removeBackCache hello.loc``
```
removeBackCache(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") rm -fr /var/www/$1/var/cache /var/www/$1/generated/metadata /var/www/$1/generated/code /var/www/$1/var/view_preprocessed /var/www/$1/var/page_cache
}
```

Clear front-end cache.
Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name as an argument. Example ``removeFrontCache hello.loc``
```
removeFrontCache(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") rm -fr /var/www/$1/var/cache /var/www/$1/var/view_preprocessed /var/www/$1/var/page_cache /var/www/$1/pub/static/frontend /var/www/$1/pub/static/_cache
}
```

Run ``php bin/magento setup:upgrade``
Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name as an argument. Example ``upgrade hello.loc``
```
upgrade(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") php /var/www/$1/bin/magento setup:upgrade
}
```

Set developer mode ``php bin/magento deploy:mode:set developer``
Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name as an argument. Example ``setDev hello.loc``
```
setDev(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") php /var/www/$1/bin/magento deploy:mode:set developer
}
```

Set developer mode ``php bin/magento deploy:mode:set production``
Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name as an argument. Example ``setProd hello.loc``
```
setProd(){
    docker exec -i $(docker ps --format "{{.Names}}" | grep "php-") php /var/www/$1/bin/magento deploy:mode:set production
}
```

Please, note that your container name MUST contain ``php-`` in the grep part.
Pass your project folder name and db name as arguments. 
Example ``installFreshMagento hello.loc test_db``
```
installFreshMagento(){
    docker exec -i $1 php /var/www/$1/bin/magento setup:install \
        --base-url=http://$1/ \
        --db-host=mysql-server \
        --db-name=$2 \
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
}
```
