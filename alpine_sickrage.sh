#!/bin/ash
user='sickrage'
group='nogroup'
dir='/opt'

echo 'Installing dependencies'
apk add git python
echo 'Creating SickRage user'
if [[ "$(grep "$user" /etc/passwd|wc -l)" -eq 0]]; then
  adduser -S $user
else
  echo 'SickRage user already exists: ' $user
echo 'Creating /opt directory'
if [ ! -d "$dir" ]; then
  mkdir /opt
fi
echo 'Cloning SickRage'
if [ ! -d "$dir/sickrage" ]; then
  git clone https://github.com/SiCKRAGETV/SickRage.git /opt/sickrage
else
  echo 'SickRage directory already exists.'
fi
echo 'Running SickRage for 10 seconds'
if [ -f "$dir/SickBeard.py" ]; then
  timeout 10 python $dir/sickrage/SickRage.py
else
  echo 'Could not find "SickRage.py". Exiting!'
  exit 1
fi
echo 'Copying init script to /etc'
if [ -f "$dir/sickrage/runscripts/init.gentoo" ]; then
  cp $dir/sickrage/runscripts/init.gentoo /etc/init.d/sickrage
else
  echo 'Could not find "init.gentoo". Exiting!'
  exit 1
fi
echo 'Creating configuration file for SickRage init script'
if [ -d /etc/conf.d ] && [ ! -f /etc/conf.d/sickrage ]; then
  echo 'SICKRAGE_USER=sickrage
  SICKRAGE_GROUP=nogroup
  SICKRAGE_DIR=/opt/sickrage
  SICKRAGE_DATADIR=/opt/sickrage
  SICKRAGE_CONFDIR=/opt/sickrage
  PATH_TO_PYTHON_2=/usr/bin/python.2.7' > /etc/conf.d/sickrage
fi
echo 'Changing SickRage Directory ownership'
chown -R $user:$group $dir/sickrage
echo 'Starting and enabling SickRage Service'
rc-service sickrage start && rc-update add sickrage default
