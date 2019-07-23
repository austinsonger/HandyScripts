# Nginx+Unicorn best-practices congifuration guide. Heartbleed fixed.
# We use latest stable nginx with fresh **openssl**, **zlib** and **pcre** dependencies.
# Some extra handy modules to use: --with-http_stub_status_module --with-http_gzip_static_module
#
# Deployment structure
#
# SERVER:
#  /etc/init.d/nginx                             (1. nginx)
#  /home/app/public_html/app_production/current  (Capistrano directory)
#
# APP:
#  config/server/production/nginx.conf           (2. nginx.conf)
#  config/server/production/nginx_host.conf      (3. nginx_host.conf)
#  config/server/production/nginx_errors.conf    (4. nginx_errors.conf)
#  config/deploy.rb                              (5. deploy.rb)
#  config/deploy/production.rb                   (6. production.rb)
#  config/server/production/unicorn.rb           (7. unicorn.rb)
#  config/server/production/unicorn_init.sh      (8. unicorn_init.sh)






cd /usr/src
wget http://nginx.org/download/nginx-1.5.13.tar.gz
tar xzvf ./nginx-1.5.13.tar.gz && rm -f ./nginx-1.5.13.tar.gz

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.32.tar.gz
tar xzvf pcre-8.32.tar.gz && rm -f ./pcre-8.32.tar.gz

wget http://www.openssl.org/source/openssl-1.0.1g.tar.gz
tar xzvf openssl-1.0.1g.tar.gz && rm -f openssl-1.0.1g.tar.gz

cd nginx-1.5.13
./configure --prefix=/opt/nginx --with-pcre=/usr/src/pcre-8.32 --with-openssl-opt=no-krb5 --with-openssl=/usr/src/openssl-1.0.1g --with-http_ssl_module --with-http_spdy_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --with-http_stub_status_module --with-http_gzip_static_module

make && make install

mkdir /tmp/client_body_temp
mkdir /opt/nginx/ssl_certs 

echo "include /home/app/public_html/app_production/current/config/server/production/nginx.conf;" > /opt/nginx/conf/nginx.conf 

vim /etc/init.d/nginx # see the config below
chmod +x /etc/init.d/nginx && update-rc.d -f nginx defaults