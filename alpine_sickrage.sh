#!/bin/ash
user='sickrage'
group='nogroup'
dir='/opt'
# Installs dependenices for SickRage
echo 'Checking dependencies'
apk add git python
# Creates sickrage user if need be
if [ -z "$(grep "$user" /etc/passwd)" ]; then
  echo 'Creating SickRage user'
  adduser -S $user
else
  echo 'SickRage user already exists: ' $user
fi
# Creates /opt directory if need be
if [ ! -d "$dir" ]; then
  echo 'Creating /opt directory'
  mkdir /opt
fi
# Clones sickrage or updates sickrage directory if a git repo
if [ ! -d "$dir/sickrage" ]; then
  echo 'Cloning SickRage'
  git clone https://github.com/SiCKRAGETV/SickRage.git /opt/sickrage
elif [ -d "$dir/sickrage/.git" ]; then
  cd $dir/sickrage
  git pull
  cd -
else
  echo 'SickRage directory already exists and is not a git repo'
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
