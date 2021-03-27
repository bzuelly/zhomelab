#!/bin/bash

gitlab-rake gitlab:backup:create

cp /etc/gitlab/gitlab.rb /mnt/freenas/bkup-gitlab/
cp /etc/gitlab/gitlab-secrets.json /mnt/freenas/bkup-gitlab/

rsync -zvh /var/opt/gitlab/backups/*.tar /mnt/freenas/bkup-gitlab/

rm /var/opt/gitlab/backups/*.tar -rf
