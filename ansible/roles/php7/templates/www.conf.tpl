[www]

user = nginx
group = nginx
listen = /var/run/php-fpm/www.sock
listen.mode = 0660

listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1


pm = dynamic

pm.max_children = 50

pm.start_servers = 5


pm.min_spare_servers = 5

pm.max_spare_servers = 35
 

;pm.process_idle_timeout = 10s;


;pm.max_requests = 500

;pm.status_path = /status
 

;ping.path = /ping

;ping.response = pong
 

;access.log = log/$pool.access.log

;access.format = "%R - %u %t \"%m %r%Q%q\" %s %f %{mili}d %{kilo}M %C%%"


slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/7.1/www-error.log
php_admin_flag[log_errors] = on

php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/7.1/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/7.1/wsdlcache

;php_value[opcache.file_cache]  = /var/lib/php/7.1/opcache
