#
# A virtual host using mix of IP-, name-, and port-based configuration
#


server {
    listen       80;
    server_name  dietandslimmingtips.co.uk www.dietandslimmingtips.co.uk;
    root   /srv/dietandslimmingtips.co.uk;
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

server {
    listen       80;
    server_name  wedding.deveaux.co.uk;

    if ($http_x_forwarded_proto = 'http') {            
        return 301 https://$server_name$request_uri;
    }

    root   /srv/dvosites/public_html;
    location / {
        try_files $uri  /index.php?$args;
    }

    # Directives to send expires headers and turn off 404 error logging.
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
       access_log off; log_not_found off; expires max;
    }
    location ~ \.php$ {
         fastcgi_pass unix:/var/run/php-fpm/www.sock;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         fastcgi_param  SITE wedding.deveaux.co.uk;
         include        fastcgi_params;
     }
}


server {
    listen       80;
    server_name  german-shepherd-puppy.co.uk www.german-shepherd-puppy.co.uk;
    root   /srv/pws-cms/public_html/hosting;
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

server {
    listen       80;
    server_name  bobbyjason.co.uk www.bobbyjason.co.uk;
    root   /srv/bobbyjason.co.uk;
    location @wp {
       rewrite ^/blog(.*) /blog/index.php?q=$1;
    }
    location ^~ /blog {
        root /srv/bobbyjason.co.uk;
        index index.php index.html index.htm;
        try_files $uri $uri/ @wp;

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_pass unix:/var/run/php-fpm/www.sock;
        }
    } 
    #ilocation / {
    #    try_files $uri $uri/ /index.php?$args;
    #}

    # Directives to send expires headers and turn off 404 error logging.
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
       access_log off; log_not_found off; expires max;
    }
}

server {
    listen       80;
    server_name  staplesbuildingservices.co.uk www.staplesbuildingservices.co.uk;
    root   /srv/staplesbuildingservices;
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

server {
    listen       80;
    server_name  sitebuilder.chopsmonster.com;
    root   /srv/chopsmonster.com/public_html/sitebuilder;
    location / {
        try_files $uri  /index.php?$args;
    }

    
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

server {
    listen       80;
    server_name  ultimate-underwear.co.uk;
    root   /srv/chopsmonster.com/public_html/compare;
    location / {
        try_files $uri  /index.php?$args;
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

