#!/bin/bash


dnf -y install curl policycoreutils postfix

systemctl enable postifix && systemctl start postfix

curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

sudo dnf install gitlab-ce -y


