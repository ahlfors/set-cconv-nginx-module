#!/bin/bash

# this file is mostly meant to be used by the author himself.

root=`pwd`
home=~
cd ~/work
version=$1
if [ -z $1 ]; then
    version=0.8.41
fi

opts=$2

rm -f ~/work/nginx-$version/objs/addon/ndk/ndk.o \
    ~/work/nginx-$version/objs/addon/ndk-nginx-module/ndk.o

if [ ! -s "nginx-$version.tar.gz" ]; then
    wget "http://sysoev.ru/nginx/nginx-$version.tar.gz" -O nginx-$version.tar.gz || exit 1
    tar -xzvf nginx-$version.tar.gz || exit 1
    if [ "$version" = "0.8.41" ]; then
        cp $root/../no-pool-nginx/nginx-$version-no_pool.patch ./
        patch -p0 < nginx-$version-no_pool.patch || exit 1
    fi
fi

#tar -xzvf nginx-$version.tar.gz || exit 1
#cp $root/../no-pool-nginx/nginx-0.8.41-no_pool.patch ./
#patch -p0 < nginx-0.8.41-no_pool.patch

cd nginx-$version/

if [[ "$BUILD_CLEAN" = 1 || ! -f Makefile || "$root/config" -nt Makefile || "$root/util/build.sh" -nt Makefile ]]; then
    ./configure --prefix=/opt/nginx \
          --with-cc-opt="-O0" \
          --with-ld-opt="-lcconv" \
          --add-module=$root/../echo-nginx-module \
          --add-module=$root/../ngx_devel_kit \
          --add-module=$root $opts \
          --with-debug \
      || exit 1
          #--add-module=$home/work/ndk \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)
fi
if [ -f /opt/nginx/sbin/nginx ]; then
    rm -f /opt/nginx/sbin/nginx
fi
if [ -f /opt/nginx/logs/nginx.pid ]; then
    kill `cat /opt/nginx/logs/nginx.pid`
fi
make -j3 && make install

