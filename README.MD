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