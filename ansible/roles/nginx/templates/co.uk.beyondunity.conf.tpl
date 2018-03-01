server {
    listen       80;
    server_name legacy.beyondunity.co.uk;
    root   /srv/beyond-unity/web;
    location / {
        index  index.php index.html index.htm;
    }

    location ~ \.php$ {
         fastcgi_pass unix:/var/run/php-fpm/www.sock;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include        fastcgi_params;
     }
}
