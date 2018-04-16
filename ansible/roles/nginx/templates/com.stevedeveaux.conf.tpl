server
{
    listen      80;
    server_name stevedeveaux.com www.stevedeveaux.com;
    root   		/srv/stevedeveaux;
    gzip 		on;
    gunzip 		on;
    location 	/
    {
        index  index.php index.html index.htm;
    }

    location ~ \.php$
    {
         fastcgi_pass unix:/var/run/php-fpm/www.sock;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include        fastcgi_params;
    }

    location ~*  \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$
    {
        expires max;
    }
}