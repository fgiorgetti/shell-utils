#!/bin/bash

CURDIR=`dirname $0`
. ${CURDIR}/read_var.sh

function error_exit() {
    echo "$*"
    exit 1
}

# User must provide OpenStack credential info first
[[ -z ${OS_PASSWORD} || -z ${OS_USERNAME} ]] && error_exit "Please provide your OpenStack credentials first"

# You can customize this based on your own project settings
read_var FLAVOR "VM flavor to use" true "m1.small" "m1.tiny" "m1.small" "m1.medium" "m1.large" "m1.xlarge"
read_var IMAGE "Snapshot image name" true "amq-ic-170-rhel-7x"
read_var KEY_NAME "Key name to log in" true "cci"
read_var NETWORK_NAME "Network name" true "provider_net_cci_1"
read_var SECURITY_GROUP "Security group" true "wide-open"
read_var VM_NAME "Virtual machine name" true

echo
echo "Virtual Machine Info"
echo " > FLAVOR         : ${FLAVOR}"
echo " > IMAGE          : ${IMAGE}"
echo " > KEY            : ${KEY_NAME}"
echo " > NETWORK        : ${NETWORK_NAME}"
echo " > SECURITY GROUP : ${SECURITY_GROUP}"
echo " > NAME           : ${VM_NAME}"
echo
read_var PROCEED "Confirm?" true "y" y Y n N
[[ ! ${PROCEED} =~ ^[yY]$ ]] && error_exit "Exiting"

echo "Creating your virtual machine ($VM_NAME)..."
openstack server create --flavor "${FLAVOR}" --image "${IMAGE}" --security-group "${SECURITY_GROUP}" --network "${NETWORK_NAME}" --key-name "${KEY_NAME}" "${VM_NAME}"

if [ $? -eq 0 ]; then
    echo "Retrieving IP Addresses"
    for ((i=0; i<3; i++)); do
        IP_ADDR=`openstack server show -c addresses -f value ${VM_NAME} | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
        [[ -n "${IP_ADDR}" ]] && break
        echo not ready... waiting 20 secs for another attempt
        sleep 20
    done
    echo "IP    : ${IP_ADDR}"
fi
