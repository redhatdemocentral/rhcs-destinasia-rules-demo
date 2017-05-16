#!/bin/sh 
DEMO="Destinasia Travel Rules Demo"
AUTHORS="Andrew Block, Eric D. Schabell, Woh Shon Phoon"
PROJECT="git@github.com:redhatdemocentral/rhcs-destinasia-rules-demo.git"
SRC_DIR=./installs
BRMS=jboss-brms-6.4.0.GA-deployable-eap7.x.zip
EAP=jboss-eap-7.0.0-installer.jar

# Adjust these variables to point to an OCP instance.
OPENSHIFT_USER=openshift-dev
OPENSHIFT_PWD=devel
HOST_IP=192.168.99.100
OCP_PRJ=appdev-in-cloud
OCP_APP=destinasia-rules-demo

# prints the documentation for this script.
function print_docs() 
{
	echo "This project can be installed on any OpenShift platform, such as OpenShift"
	echo "Container Platform or Red Hat Container Development Kit. It's possible to"
	echo "install it on any available installation by pointing this installer to an"
	echo "OpenShift IP address:"
	echo
	echo "   $ ./init.sh IP"
	echo
	echo "If using Red Hat OCP, IP should look like: 192.168.99.100"
	echo
}

# check for a valid passed IP address.
function valid_ip()
{
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi

	return $stat
}

# wipe screen.
clear 

echo
echo "#######################################################################"
echo "##                                                                   ##"   
echo "##  Setting up the ${DEMO}                      ##"
echo "##                                                                   ##"   
echo "##                                                                   ##"   
echo "##  ####  ####  #   #  ####        #### #      ###  #   # ####       ##"
echo "##  #   # #   # ## ## #       #   #     #     #   # #   # #   #      ##"
echo "##  ####  ####  # # #  ###   ###  #     #     #   # #   # #   #      ##"
echo "##  #   # # #   #   #     #   #   #     #     #   # #   # #   #      ##"
echo "##  ####  #  #  #   # ####         #### #####  ###   ###  ####       ##"
echo "##                                                                   ##"   
echo "##  brought to you by,                                               ##"   
echo "##             ${AUTHORS}        ##"
echo "##                                                                   ##"   
echo "##  ${PROJECT}  ##"
echo "##                                                                   ##"   
echo "#######################################################################"
echo

# validate OpenShift host IP.
if [ $# -eq 1 ]; then
	if [ $(valid_ip $1) ] || [ $1 == $HOST_IP ]; then
		echo "OpenShift host given is a valid IP..."
		HOST_IP=$1
		echo
		echo "Proceeding with OpenShift host: $HOST_IP..."
		echo
	else
		# bad argument passed.
		echo "Please provide a valid IP that points to an OpenShift installation..."
		echo
		print_docs
		echo
		exit
	fi
elif [ $# -gt 1 ]; then
	print_docs
	echo
	exit
else
	# no arguments, prodeed with default host.
	print_docs
	echo
	exit
fi

# make some checks first before proceeding.	
command -v oc -v >/dev/null 2>&1 || { echo >&2 "OpenShift command line tooling is required but not installed yet... download here: https://access.redhat.com/downloads/content/290"; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product EAP sources are present...
	echo
else
	echo Need to download $EAP package from https://developers.redhat.com/products/eap/download
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BRMS ] || [ -L $SRC_DIR/$BRMS ]; then
	echo Product BRMS sources are present...
	echo
else
	echo Need to download $BRMS from https://developers.redhat.com/products/bpmsuite/download
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

echo "OpenShift commandline tooling is installed..."
echo 
echo "Logging in to OpenShift as $OPENSHIFT_USER..."
echo
oc login $HOST_IP:8443 --password=$OPENSHIFT_PWD --username=$OPENSHIFT_USER

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc login' command!
	exit
fi

echo
echo "Creating a new project..."
echo
oc new-project $OCP_PRJ

echo
echo "Setting up a new build..."
echo
oc new-build "jbossdemocentral/developer" --name=$OCP_APP --binary=true

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc new-build' command!
	exit
fi

# need to wait a bit for new build to finish with developer image.
sleep 10   

echo
echo "Importing developer image..."
echo
oc import-image developer

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc import-image' command!
	exit
fi

echo
echo "Starting a build, this takes some time to upload all of the product sources for build..."
echo
oc start-build $OCP_APP --from-dir=. --follow=true --wait=true

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc start-build' command!
	exit
fi

# need to wait a bit for new build to finish with developer image.
sleep 3

echo
echo "Creating a new application..."
echo
oc new-app $OCP_APP

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc new-app' command!
	exit
fi

echo
echo "Creating an externally facing route by exposing a service..."
echo
oc expose service $OCP_APP --port=8080 --hostname="$OCP_APP.$HOST_IP.xip.io"

if [ "$?" -ne "0" ]; then
	echo
	echo Error occurred during 'oc expose service' command!
	exit
fi

echo
echo "==========================================================================="
echo "=                                                                         ="
echo "=  Login to JBoss BRMS to start developing rules projects:                ="
echo "=                                                                         ="
echo "=  http://$OCP_APP.$HOST_IP.xip.io/business-central    ="
echo "=                                                                         ="
echo "=  [ u:erics / p:jbossbrms1! ]                                            ="
echo "=                                                                         ="
echo "=  Note: it takes a few minutes to expose the service...                  ="
echo "=                                                                         ="
echo "==========================================================================="

