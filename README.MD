## Docker Image
Stack:
- Nginx
- PHP FPM 8.1
- Maria DB 10.4
- Elasticsearch 7.14.0
- Phpmyadmin 5.0.1

## How to use

### Test run:
1) Install Docker and Docker compose
2) Clone the repository to your local machine
3) Modify your hosts file by adding these two lines or your own:
```
127.0.0.1 hello.loc
127.0.0.1 phpmyadmin.loc
```
4) Run ``docker compose up -d`` from the root folder you just cloned
5) Go ``http://hello.loc/`` to see PHP info default page or ``http://phpmyadmin.loc`` to see phpmyadmin panel to wor with databases

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
8) Don't forget to add your new domain ``my-new-project.loc`` to your computer hosts file
9) Go ``http://my-new-project.loc/`` to see your project

### Configure Magento:
10) Create ``auth.json`` file in the root of your magento project. Fill it with your Adobe account keys and with your github oath key. Any extra credentials for any 3-rd party extensions can be added as well. Example:
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

## Bonus
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
