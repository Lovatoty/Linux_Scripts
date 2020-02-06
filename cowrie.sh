#!/bin/bash

apt-get remove openssh*
apt-get install git python-virtualenv libssl-dev libffi-dev build-essential libpython-dev python2.7-minimal authbind
adduser --disabled-password cowrie
su - cowrie
git clone http://github.com/micheloosterhof/cowrie
cd cowrie
virtualenv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
cp cowrie.cfg.dist cowrie.cfg
