#!/bin/bash


#Installs the package needed for semanage
yum install -y policycoreutils-python.x86x64

#Tells us if selinux is enforced
getenforce

