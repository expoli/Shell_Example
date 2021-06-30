#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
set -x

DHCP_INTSERFACE_CONF="/etc/default/isc-dhcp-server"
DHCP_DHCPD_CONF="/etc/dhcp/dhcpd.conf"
DHCP_SERVICE_NAME="isc-dhcp-server"
DHCP_BIN_PATH="/usr/sbin/dhcpd"

BACKUP_FILE_SUFFIX=".example"
PACKAGE_NAME="isc-dhcp-server"

NETWORK_CONFIG_FILE="/etc/netplan/dhcp-static-ip.yaml"

DATE=$(date +%F-%H-%M-%S)

declare  INTERFACE_NAME
declare  TEMP=99999

declare -A DEFAULT_CONFIG_VALUE

function checkExistngConfig() {
    if [[ -f ${1} ]]; then
        read -r -p "You has been run this script already, do you want to run it anyway ?" confim
        if [[ ! "$confim" =~ y|Y ]]; then
            exit 1
        else
            TEMP=0
        fi
    fi
}

function checkOs() {
    if [[ ! "$(lsb_release -i -s 2>/dev/null)" =~ Ubuntu|Kali ]]; then
        read -r -p "This script SHOULD ONLY be run on Ubuntu or Kali, run at your own RISK: (y/n)" agree
        if [[ ! "$agree" =~ y|Y ]]; then
            exit 1
        fi
        agree=''
    else
        export DEBIAN_FRONTEND=noninteractive
    fi
    declare -A backup_files
    backup_files[0]+=${DHCP_INTSERFACE_CONF}${BACKUP_FILE_SUFFIX}
    backup_files[1]+=${DHCP_DHCPD_CONF}${BACKUP_FILE_SUFFIX}
    backup_files[2]+=${NETWORK_CONFIG_FILE}${BACKUP_FILE_SUFFIX}
    for i in "${!backup_files[@]}"; do
        checkExistngConfig ${backup_files[${i}]}
        res=${TEMP}
        if [[ ${res} == 0 ]]; then
            break;
        fi
    done
}

function checkRoot() {
    if [[ $EUID -eq 0 ]]; then
        echo
    else
        echo "This script SHOULD run as root, please run it again"
        exit 1
    fi
}

function installDependents() {
    if [[ ! -f ${DHCP_BIN_PATH} ]]; then
        apt update && apt install $PACKAGE_NAME -y
    fi
}

function getAllInterfaceName() {
    echo ip a | grep -e "^[0-9]:" | awk -F : '{printf $2}'
    TEMP=$(ip a | grep -e "^[0-9]:" | awk -F : '{printf $2}')
}

function choiceInterfaceName() {
    echo 
        ip a
    echo
    getAllInterfaceName
    read -r -p "please input interface name which you want to configure." interfaceName 
    echo 
    allIntetfaceName=${TEMP}
    echo "${allIntetfaceName}"

    # while (( 1 )); do
        if [[ ${interfaceName} != null ]]; then
            if [[ ${allIntetfaceName[*]} =~ ${interfaceName} ]]; then
                echo "Ok! interface ${interfaceName} exists!"
                INTERFACE_NAME=${interfaceName}
                # break
            else
                echo "Error! interface input error! Input it again"
                read -r -p "please input interface name which you want to configure." interfaceName 
            fi
        else
            echo "Please input something."
        fi
    # done
}

function checkIpAddr() {
    read -r -p "${1}" subnet_addr
    while (( 1 )); do
        check_res=$(getIpAddrFromInput "${subnet_addr}")
        if [[ ${check_res} != 1 ]]; then
            TEMP=${subnet_addr}
            break;
        else
            echo "input error! input again"
            fi
    done
}

function getIpAddrFromInput() {
    if [[ $1 =~ ^((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}$ ]]; then
        echo "${subnet_addr}"
    else
        return 1
    fi
}

function manualConfigSubnetInfo() {
    checkIpAddr "input the dhcp server subnet ip addr"
    DEFAULT_CONFIG_VALUE+=(['subnet_addr']=${TEMP})
    checkIpAddr "input the dhcp server subnet ip mask"
    DEFAULT_CONFIG_VALUE+=(['subnet_mask']=${TEMP})
    checkIpAddr "input the dhcp server subnet ip range begin"
    DEFAULT_CONFIG_VALUE+=(['subnet_rang_begin']=${TEMP})
    checkIpAddr "input the dhcp server subnet ip range end"
    DEFAULT_CONFIG_VALUE+=(['subnet_rang_end']=${TEMP})
}

function configDhcpdConf() {
    if [[ ! -f ${DHCP_DHCPD_CONF}${BACKUP_FILE_SUFFIX} ]]; then
        cp ${DHCP_DHCPD_CONF} ${DHCP_DHCPD_CONF}${BACKUP_FILE_SUFFIX}
    else
        cp ${DHCP_DHCPD_CONF} ${DHCP_DHCPD_CONF}."${DATE}"
    fi
    cat <<EOF > ${DHCP_DHCPD_CONF}
#option domain-name "example.org";
option domain-name-servers 8.8.8.8, 1.0.0.1;
subnet ${DEFAULT_CONFIG_VALUE['subnet_addr']} netmask ${DEFAULT_CONFIG_VALUE['subnet_mask']} {
    range ${DEFAULT_CONFIG_VALUE[subnet_rang_begin]} ${DEFAULT_CONFIG_VALUE[subnet_rang_end]};
}
EOF
}

function configDhcpInterfaceName() {
    if [[ ! -f ${DHCP_INTSERFACE_CONF} ]]; then
        sed -i.example "s/INTERFACESv4=\"\"/INTERFACESv4=\"${INTERFACE_NAME}\"/g" ${DHCP_INTSERFACE_CONF}
    else
        sed -i."${DATE}" "s/INTERFACESv4=\"\"/INTERFACESv4=\"${INTERFACE_NAME}\"/g" ${DHCP_INTSERFACE_CONF}
    fi
}

function IPprefix_by_netmask() {
    #function returns prefix for given netmask in arg1
    bits=0
    for octet in $(echo $1 | sed 's/\./ /g'); do 
         binbits=$(echo "obase=2; ibase=10; ${octet}"| bc | sed 's/0//g') 
         (( bits+=${#binbits} ))
    done
    echo "/${bits}"
    TEMP="/${bits}"
}

function configInterfaceIpAddr() {
    staic_ip_addr=${DEFAULT_CONFIG_VALUE['static_ip_addr']}
    cidr=$(IPprefix_by_netmask "${DEFAULT_CONFIG_VALUE['subnet_mask']}")
    staic_ip_addr_with_cidr=${staic_ip_addr}${cidr}
    if [[ ! -f ${NETWORK_CONFIG_FILE}${BACKUP_FILE_SUFFIX} ]]; then
        # sed -i.example "/version*/ a\ethernets:\n    ${INTERFACE_NAME}:\n      addresses:\n        - ${staic_ip_addr_with_cidr}\n      nameservers:\n          addresses: [8.8.8.8, 1.1.1.1]"  ${NETWORK_CONFIG_FILE} 
        mv ${NETWORK_CONFIG_FILE} ${NETWORK_CONFIG_FILE}${BACKUP_FILE_SUFFIX}
        cat <<EOF > ${NETWORK_CONFIG_FILE}
network:
  version: 2
  ethernets:
    ${INTERFACE_NAME}:
      dhcp4: no
      addresses:
        - DEFAULT_CONFIG_VALUE['staic_ip_addr_with_cidr']
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
EOF
    else
        mv ${NETWORK_CONFIG_FILE} ${NETWORK_CONFIG_FILE}."${DATE}"
        cat <<EOF > ${NETWORK_CONFIG_FILE}
network:
  version: 2
  ethernets:
    ${INTERFACE_NAME}:
      dhcp4: no
      addresses:
        - ${DEFAULT_CONFIG_VALUE['staic_ip_addr_with_cidr']}
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
EOF
    fi
}

function manualConfigInterfaceStaticIp() {
    checkIpAddr "input the static ip for ${INTERFACE_NAME}"
    DEFAULT_CONFIG_VALUE['static_ip_addr']+=${TEMP}
    configInterfaceIpAddr
}

function startService() {
    netplan apply
    networkctl
    echo 
    systemctl enable ${DHCP_SERVICE_NAME}
    systemctl stop ${DHCP_SERVICE_NAME}
    systemctl start ${DHCP_SERVICE_NAME}

}

function configDefaultValue() {
    DEFAULT_CONFIG_VALUE+=(['subnet_addr']="192.168.233.0")
    DEFAULT_CONFIG_VALUE+=(['subnet_mask']="255.255.255.0")
    DEFAULT_CONFIG_VALUE+=(['subnet_rang_begin']="192.168.233.100")
    DEFAULT_CONFIG_VALUE+=(['subnet_rang_end']="192.168.233.200")
    DEFAULT_CONFIG_VALUE+=(['static_ip_addr']="192.168.233.1")
    IPprefix_by_netmask "${DEFAULT_CONFIG_VALUE['subnet_mask']}"
    
    DEFAULT_CONFIG_VALUE+=(['staic_ip_addr_with_cidr']=${DEFAULT_CONFIG_VALUE['static_ip_addr']}${TEMP})
    
}

function autoConfig() {

    configDefaultValue
    choiceInterfaceName

    configDhcpdConf
    configInterfaceIpAddr
}

function manualConfig() {
    choiceInterfaceName
    manualConfigSubnetInfo
    configDhcpdConf

    manualConfigInterfaceStaticIp
}

function main() {
    echo "chinking os ..."
    checkOs
    checkRoot
    installDependents

    read -r -p "Do you want to config ${PACKAGE_NAME} by yourself? (y/n)" confim
    if [[ ! "$confim" =~ y|Y ]]; then
        autoConfig
    else
        manualConfig
    fi
    # startService
    echo "Congratulations config done!"
    exit 0
}

main

