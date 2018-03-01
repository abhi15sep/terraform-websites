server {
    listen 80;
    server_name crazybulkerhttp.co.uk crazybulker.co.uk www.crazybulker.co.uk;
    #server_name crazybulkerhttp.co.uk;
    
    root   /srv/crazybulker.co.uk;   

    #location / {
    #    try_files $uri $uri/ /index.php?$args;
    #}
    
    pagespeed on;
    pagespeed FileCachePath "/dev/shm/ngx_pagespeed/";
    
    set $cache_uri $request_uri;
    # POST requests and urls with a query string should always go to PHP
    if ($request_method = POST) {
        set $cache_uri 'null cache'; 
    }   
        if ($query_string != "") {
                set $cache_uri 'null cache';
        }

        # Don't cache uris containing the following segments
        if ($request_uri ~* "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(_index)?.xml|[a-z0-9_-]+-sitemap([0-9]+)?.xml)") {
                set $cache_uri 'null cache';
        }

        # Don't use the cache for logged in users or recent commenters
        if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in") {
                set $cache_uri 'null cache';
        }

        # Use cached or actual file if they exists, otherwise pass request to WordPress
        location / {
                try_files /wp-content/cache/supercache/$http_host/$scheme$cache_uri/index.html $uri $uri/ /index.php ;
        }

        location = /favicon.ico { log_not_found off; access_log off; }
        location = /robots.txt  { log_not_found off; access_log off; }
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    # Add trailing slash to */wp-admin requests.
    rewrite /wp-admin$ $scheme://$host$uri/ permanent;

    # Directives to send expires headers and turn off 404 error logging.
    #location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
    #   access_log off; log_not_found off; expires max;
    #}
    location ~ \.php$ {
         fastcgi_pass   127.0.0.1:9000;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include        fastcgi_params;
     }

}

server {
    #listen       80;
    #server_name  crazybulker.co.uk www.crazybulker.co.uk;
     
    #return         301 https://$server_name$request_uri;
}

server {
    #listen       443;
    listen 443 ssl spdy;
    ssl    on;
    ssl_certificate      /etc/ssl/certs/crazybulkerbundle.crt;
    ssl_certificate_key  /etc/pki/tls/private/crazybulker.key;

    server_name  crazybulker.co.uk www.crazybulker.co.uk;
    root   /srv/crazybulker.co.uk;

    pagespeed on;
    pagespeed RewriteLevel CoreFilters;
    pagespeed FileCachePath "/dev/shm/ngx_pagespeed/";
    pagespeed MapOriginDomain "http://crazybulkerhttp.co.uk" "https://crazybulker.co.uk";
    #pagespeed FetchHttps enable;
    pagespeed Statistics on;
    pagespeed StatisticsLogging on;
    pagespeed LogDir /var/log/pagespeed;
    pagespeed AdminPath /pagespeed_admin;

    location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" { add_header "" ""; }
    location ~ "^/ngx_pagespeed_static/" { }
    location ~ "^/ngx_pagespeed_beacon$" { }
    location /ngx_pagespeed_statistics { allow 127.0.0.1; deny all; }
    location /ngx_pagespeed_message { allow 127.0.0.1; deny all; }
    location /pagespeed_console { allow 127.0.0.1; deny all; }

    set $cache_uri $request_uri;
    # POST requests and urls with a query string should always go to PHP
    if ($request_method = POST) {
	set $cache_uri 'null cache';
    }   
	if ($query_string != "") {
		set $cache_uri 'null cache';
	}   

	# Don't cache uris containing the following segments
	if ($request_uri ~* "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(_index)?.xml|[a-z0-9_-]+-sitemap([0-9]+)?.xml)") {
		set $cache_uri 'null cache';
	}   

	# Don't use the cache for logged in users or recent commenters
	if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in") {
		set $cache_uri 'null cache';
	}

	# Use cached or actual file if they exists, otherwise pass request to WordPress
	location / {
		try_files /wp-content/cache/supercache/$http_host/$scheme$cache_uri/index.html $uri $uri/ /index.php ;
	}    

	location = /favicon.ico { log_not_found off; access_log off; }
	location = /robots.txt  { log_not_found off; access_log off; }

    #location / {
    #    try_files $uri $uri/ /index.php?$args;
    #}

    gzip on;
    gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    # Add trailing slash to */wp-admin requests.
    rewrite /wp-admin$ $scheme://$host$uri/ permanent;

    # Directives to send expires headers and turn off 404 error logging.
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
       access_log off; log_not_found off; expires max;
    }
    location ~ \.php$ {
         fastcgi_pass   127.0.0.1:9000;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include        fastcgi_params;
     }
}