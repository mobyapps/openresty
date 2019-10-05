#!/bin/bash

set -eux

chown -R user7:group7    /usr/local/openresty

/usr/local/openresty/nginx/sbin/nginx

chown -R user7:group7    /usr/local/openresty
