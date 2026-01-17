#!/bin/bash

PCRE=pcre2-10.47
ZLIB=zlib-1.3.1
OPENSSL=openssl-3.5.4

if [ ! -f ../$OPENSSL.tar.gz ]; then curl -Lo ../$OPENSSL.tar.gz https://github.com/openssl/openssl/releases/download/$OPENSSL/$OPENSSL.tar.gz; fi
if [ ! -f ../$ZLIB.tar.gz ]; then curl -Lo ../$ZLIB.tar.gz https://www.zlib.net/$ZLIB.tar.gz; fi
if [ ! -f ../$PCRE.tar.gz ]; then curl -Lo ../$PCRE.tar.gz https://github.com/PCRE2Project/pcre2/releases/download/$PCRE/$PCRE.tar.gz; fi

rm -rf objs || exit 1
mkdir -p objs/lib || exit 1
cd objs/lib || exit 1
ls ../../..
tar -xzf ../../../$OPENSSL.tar.gz || exit 1
tar -xzf ../../../$ZLIB.tar.gz || exit 1
tar -xzf ../../../$PCRE.tar.gz || exit 1
cd ../..

cd objs/lib/$OPENSSL || exit 1
patch -p1 < ../../../patches/openssl-3.5.4-sess_set_get_cb_yield.patch || exit 1
cd ../../..

./configure \
    --with-cc=cc \
    --prefix= \
    --with-cc-opt='-DFD_SETSIZE=1024' \
    --sbin-path=nginx.exe \
    --with-pcre-jit \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
    --without-lua_rds_parser \
    --with-mail \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_v2_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_secure_link_module \
    --with-http_random_index_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_slice_module \
    --with-select_module \
    --with-luajit-xcflags="-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT" \
    --with-pcre=objs/lib/$PCRE \
    --with-zlib=objs/lib/$ZLIB \
    --with-openssl=objs/lib/$OPENSSL \
    --with-openssl-opt='no-asm no-tests no-makedepend -D_WIN32_WINNT=0x0501' \
    --with-http_ssl_module \
    --with-mail_ssl_module \
    -j`nproc` || exit 1

make -j`nproc` || exit 1
make install
