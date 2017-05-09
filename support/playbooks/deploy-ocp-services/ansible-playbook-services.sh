#!/bin/sh 

# Setup environment.
export OC_LOC=$(which oc)
export SED_LOC=$(which sed)
export AWK_LOC=$(which awk)

# make some checks first before proceeding.	
command -v sed >/dev/null 2>&1 || { echo; echo "Missing essential command, please install 'sed' to continue..."; echo; exit 1; }
command -v awk >/dev/null 2>&1 || { echo; echo "Missing essential command, please install 'awk' to continue..."; echo; exit 1; }
command -v ansible-playbook --version  >/dev/null 2>&1 || { echo; echo "Missing essential command 'ansible-playbook', please install Ansible to continue..."; echo; exit 1; }

echo 
echo "If you followed the first steps to setup the Destinasia Travel Rules on OpenShift Container Platform,"
echo "the following will install the all the services now..."
echo
ansible-playbook -v -i hosts site.yml
