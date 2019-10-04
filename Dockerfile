FROM phusion/baseimage:0.11

LABEL maintainer="charescape@outlook.com"

ENV RESTY_VERSION 1.15.8.2

COPY ./startserv.sh               /etc/my_init.d/
COPY ./conf/nginx.conf            /usr/local/src/

# see http://www.ruanyifeng.com/blog/2017/11/bash-set.html
RUN set -eux \
&& export DEBIAN_FRONTEND=noninteractive \
&& sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/http:\/\/security.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/archive.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/security.ubuntu.com/https:\/\/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
&& apt-get -y update            \
&& apt-get -y upgrade           \
&& apt-get -y install build-essential \
wget                            \
curl                            \
libssl-dev                      \
zlib1g-dev                      \
libpcre3-dev                    \
libgeoip-dev                    \
libevent-dev                    \
libxml2-dev                     \
libxslt1-dev                    \
socat                           \
\
&& groupadd group7 \
&& useradd -g group7 -M -d /usr/local/openresty user7 -s /sbin/nologin \
\
&& chmod +x /etc/my_init.d/startserv.sh \
\
&& cd /usr/local/src \
\
&& wget https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz \
&& tar -zxf openresty-${RESTY_VERSION}.tar.gz \
\
&& cd /usr/local/src/openresty-${RESTY_VERSION} \
&& ./configure --prefix=/usr/local/openresty \
--with-threads \
--with-file-aio \
--with-http_v2_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_auth_request_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_stub_status_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--with-stream=dynamic \
--with-stream_ssl_module \
--with-stream_realip_module \
--with-stream_ssl_preread_module \
--with-pcre \
--with-pcre-jit \
--with-http_geoip_module=dynamic \
--with-stream_geoip_module=dynamic \
--with-http_xslt_module=dynamic \
\
&& make && make install \
\
&& mkdir /usr/local/openresty/nginx/vhosts \
&& mkdir /usr/local/openresty/nginx/vconfs \
&& mkdir /usr/local/openresty/nginx/vlogs \
&& mkdir /usr/local/openresty/nginx/vcerts \
\
&& cd /usr/local/src \
&& yes | cp ./nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf \
\
&& chown -R user7:group7 /usr/local/openresty \
&& /usr/local/openresty/nginx/sbin/nginx -t \
&& /usr/local/openresty/nginx/sbin/nginx \
&& sleep 3s \
&& /usr/local/openresty/nginx/sbin/nginx -s stop \
\
&& echo '' >> ~/.bashrc \
&& echo 'export PATH="$PATH:/usr/local/openresty/nginx/sbin"' >> ~/.bashrc \
\
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& rm -rf /usr/local/src/*

EXPOSE 80 443

CMD ["/sbin/my_init"]

# source ~/.bashrc
# curl  https://get.acme.sh | sh
