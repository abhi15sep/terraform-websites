server {
    listen       80;
    server_name  crazybulker.co.uk www.crazybulker.co.uk;
    root   /srv/crazybulker.co.uk;
    location / {
        try_files $uri /index.php?$args;
    }

    # Directives to send expires headers and turn off 404 error logging.
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
       access_log off; log_not_found off; expires max;
    }
    location ~ \.php$ {
         fastcgi_pass unix:/var/run/php-fpm/www.sock;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include        fastcgi_params;
     }
}