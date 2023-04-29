#!/bin/bash
set -e

AUTH="-u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD}"
AUTH_DB="$AUTH ${MYSQL_DATABASE}"

for i in 1 2 3 4 5 6 7 8 9 10
do
    mysqladmin -h mysql $AUTH ping > /dev/null 2>&1 && break
    sleep 10
done

if ! mysql -h mysql $AUTH_DB -e 'SELECT 1 FROM abrakadabra' > /dev/null 2>&1; then
	mysql -h mysql $AUTH_DB < ./doc/authen_pause.schema.txt
fi
if ! mysql -h mysql $AUTH_DB -e 'SELECT 1 FROM applymod' > /dev/null 2>&1; then
	mysql -h mysql $AUTH_DB < ./doc/mod.schema.txt
fi

cd /root
tar xf /root/gnupg.tar.gz
cp -R /root/gnupg/* /root/.gnupg/
cd /home/k/pause
chmod 0600 /root/.gnupg/*
chmod 0600 /root/.gnupg/private-keys-v1.d
chmod 0600 /root/.gnupg/openpgp-revocs.d
chmod 0700 /root/.gnupg

perl -Ilib ./docker/app/insert_fixture.pl

if [ ! -d /home/ftp/incoming ]; then
	mkdir /home/ftp/incoming
fi
if [ ! -d /home/ftp/run ]; then
	mkdir /home/ftp/run
fi
if [ ! -d /home/ftp/pub/PAUSE ]; then
	mkdir /home/ftp/pub/PAUSE
fi
if [ ! -d /home/ftp/pub/PAUSE/PAUSE-git ]; then
    mkdir -p /home/ftp/pub/PAUSE/PAUSE-git
    cd /home/ftp/pub/PAUSE/PAUSE-git
    git config --global init.defaultBranch main
    git init
    git config --global --add safe.directory /home/ftp/pub/PAUSE/PAUSE-git
    git config --global user.email "${FTP}"
    git config --global user.name "PAUSE-git"
    cd /home/k/pause
fi
if [ ! -d /home/ftp/pub/PAUSE/PAUSE-data ]; then
    mkdir -p /home/ftp/pub/PAUSE/PAUSE-data
fi
if [ ! -d /home/ftp/pub/PAUSE/modules ]; then
    mkdir -p /home/ftp/pub/PAUSE/modules
fi

cpm install -g

perl ./bin/paused --pidfile=/var/run/paused.pid &

# Or cron won't run it...
chmod 0600 /var/spool/cron/crontabs/root

exec rsyslogd &
exec crond &

plackup ./app_2017.psgi
