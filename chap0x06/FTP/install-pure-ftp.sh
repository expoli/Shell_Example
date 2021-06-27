#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
# set -x

# PURE_FTP_CONFIG_ROOT_PATH="./test/pure-ftpd/"
PURE_FTP_CONFIG_ROOT_PATH="/etc/pure-ftpd/"
PURE_FTP_CONFIG_NAMR="pure-ftpd.conf"
PURE_FTP_DIR_ALIASES_NAME="pureftpd-dir-aliases"
PURE_FTP_PARAMETER_CONFIG_DIR=${PURE_FTP_CONFIG_ROOT_PATH}"conf"
BACKUP_FILE_SUFFIX=".example"
PACKAGE_NAME="pure-ftpd"
DATE=$(date +%F-%H-%M-%S)

declare -A CONFIG_DETAIL
declare -A CONFIG_DEFAULT_VALUE


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

}

function checkRoot() {
    if [[ $EUID -eq 0 ]]; then
        echo
    else
        echo "This script SHOULD run as root, please run it again"
        exit 1
    fi
}

function backupConfigFile() {
    filepath=$1
    if [[ -f "${filepath}"${BACKUP_FILE_SUFFIX} ]]; then
        cp "${filepath}" "${filepath}"${BACKUP_FILE_SUFFIX}_"${DATE}"
        echo "Backup ${filepath} to ${filepath}${BACKUP_FILE_SUFFIX}_${DATE}"
        finish=1
    elif [[ -d "${filepath}"${BACKUP_FILE_SUFFIX} ]]; then
        mv "${filepath}" "${filepath}"${BACKUP_FILE_SUFFIX}_"${DATE}"
        echo "Backup ${filepath} to ${filepath}${BACKUP_FILE_SUFFIX}_${DATE}"
        mkdir -p ${filepath}
        finish=1
    fi

    if [[ ! -n ${finish} ]]; then
        echo "Backing up ${filepath} ..."
        mv "${filepath}" "${filepath}"${BACKUP_FILE_SUFFIX}
        if [[ $? != '0' ]]; then
            echo 'Backup Error! Exiting... make sure the file is exist'
            exit 1
        else
            echo 'Backup Success'
        fi
    fi
}

function backupFtpDefaultConfig() {
    backupConfigFile ${PURE_FTP_CONFIG_ROOT_PATH}${PURE_FTP_CONFIG_NAMR}
    backupConfigFile ${PURE_FTP_CONFIG_ROOT_PATH}${PURE_FTP_DIR_ALIASES_NAME}
    backupConfigFile ${PURE_FTP_PARAMETER_CONFIG_DIR}
}

function installDependents() {
    apt update && apt install $PACKAGE_NAME -y
}

function setConfigDetail() {

    CONFIG_DETAIL+=(['VerboseLog']="If you want to log all client commands, set this to \"yes\". 
    This directive can be specified twice to also log server responses.
    Default value: no")
    CONFIG_DEFAULT_VALUE+=(['VerboseLog']="no")

    CONFIG_DETAIL+=(['DisplayDotFiles']="List dot-files even when the client doesn't send \"-a\".
    Default value: no")
    CONFIG_DEFAULT_VALUE+=(['DisplayDotFiles']="no")

    CONFIG_DETAIL+=(['PAMAuthentication']="If you want to enable PAM authentication, type yes.
    Default value: yes")
    CONFIG_DEFAULT_VALUE+=(['PAMAuthentication']="yes")

    CONFIG_DETAIL+=(['ForcePassiveIP']="Force an IP address in PASV/EPSV/SPSV replies. - for NAT.
    Symbolic host names are also accepted for gateways with dynamic IP addresses.
    Default value: \"\"")

    CONFIG_DETAIL+=(['AnonymousBandwidth']="Maximum bandwidth for anonymous users in KB/s.
    Default value: 1024")
    CONFIG_DEFAULT_VALUE+=(['AnonymousBandwidth']="1024")

    CONFIG_DETAIL+=(['AnonymousCantUpload']="Prevent anonymous users from uploading new files (no = upload is allowed).
    Default value: yes")
    CONFIG_DEFAULT_VALUE+=(['AnonymousCantUpload']="yes")

    CONFIG_DETAIL+=(['AltLog']="Create an additional log file with transfers logged in a Apache-like format.
    Default value: clf:/var/log/pureftpd.log")
    CONFIG_DEFAULT_VALUE+=(['AltLog']="clf:/var/log/pureftpd.log")

    CONFIG_DETAIL+=(['MaxDiskUsage']="This option is useful on servers where anonymous upload is allowed.
    When the partition is more that percententage full, new uploads are disallowed.
    Default value: 95")
    CONFIG_DEFAULT_VALUE+=(['MaxDiskUsage']="95")

    CONFIG_DETAIL+=(['CertFileAndKey']="CertFile is for a cert+key bundle, CertFileAndKey for separate files.
    Default value: \"\"")

    CONFIG_DETAIL+=(['IPV4Only']="Listen only to IPv4 addresses in standalone mode (ie. disable IPv6) By default, both IPv4 and IPv6 are enabled.")
    CONFIG_DETAIL+=(['IPV6Only']="Listen only to IPv6 addresses in standalone mode (i.e. disable IPv4) By default, both IPv4 and IPv6 are enabled.")

    CONFIG_DETAIL+=(['TLS']="This option accepts three values:
    0: disable SSL/TLS encryption layer (default).
    1: accept both cleartext and encrypted sessions.
    2: refuse connections that don't use the TLS security mechanism,
    including anonymous sessions.
    Do _not_ uncomment this blindly. Double check that:
    1) The server has been compiled with TLS support (--with-tls),
    2) A valid certificate is in place,
    3) Only compatible clients will log in.")

    CONFIG_DETAIL+=(['CustomerProof']="Be 'customer proof': forbids common customer mistakes such as 'chmod 0 public_html',
    that are valid, but can cause customers to unintentionally shoot themselves in the foot.
    Default value: yes")
    CONFIG_DEFAULT_VALUE+=(['CustomerProof']="yes")

    CONFIG_DETAIL+=(['Quota']="Enable virtual quotas. The first value is the max number of files.
    The second value is the maximum size, in megabytes. So 1000:10 limits every user to 1000 files and 10 MB.
    Default value: \"\"")

    CONFIG_DETAIL+=(['TrustedIP']="Only connections to this specific IP address are allowed to be
    non-anonymous. You can use this directive to open several public IPs for
    anonymous FTP, and keep a private firewalled IP for remote administration.
    You can also only allow a non-routable local IP (such as 10.x.x.x) for
    authenticated users, and run a public anon-only FTP server on another IP.
    Default vlaue: \"\"")

    # CONFIG_DETAIL+=(['Umask']="File creation mask. <umask for files>:<umask for dirs> .
    # 177:077 if you feel paranoid.
    # Default value: 133:022")
    # CONFIG_DEFAULT_VALUE+=(['Umask']="133:022")

    CONFIG_DETAIL+=(['DontResolve']="Don't resolve host names in log files. Recommended unless you trust
    reverse host names, and don't care about DNS resolution being possibly slow.
    Deault value: yes")
    CONFIG_DEFAULT_VALUE+=(['DontResolve']="yes")

    CONFIG_DETAIL+=(['Bind']="Bind                         127.0.0.1,21
    'ls' recursion limits. The first argument is the maximum number of
    files to be displayed. The second one is the max subdirectories depth.
    Default vlaue: \"\"")

    CONFIG_DETAIL+=(['LimitRecursion']="'ls' recursion limits. The first argument is the maximum number of
    files to be displayed. The second one is the max subdirectories depth.
    Default vlaue: 2000 8")
    CONFIG_DEFAULT_VALUE+=(['LimitRecursion']="2000 8")

    CONFIG_DETAIL+=(['LDAPConfigFile']="LDAP configuration file (see README.LDAP)
    Default vlaue: /etc/pureftpd-ldap.conf")
    CONFIG_DEFAULT_VALUE+=(['LDAPConfigFile']="/etc/pureftpd-ldap.conf")

    CONFIG_DETAIL+=(['MySQLConfigFile']="MySQL configuration file (see README.MySQL)
    Default vlaue: /etc/pureftpd-mysql.conf")
    CONFIG_DEFAULT_VALUE+=(['MySQLConfigFile']="/etc/pureftpd-mysql.conf")

    CONFIG_DETAIL+=(['PGSQLConfigFile']="PostgreSQL configuration file (see README.PGSQL)
    Default vlaue: /etc/pureftpd-pgsql.conf")
    CONFIG_DEFAULT_VALUE+=(['PGSQLConfigFile']="/etc/pureftpd-pgsql.conf")

    CONFIG_DETAIL+=(['PureDB']="PureDB user database (see README.Virtual-Users)
    Default vlaue: /etc/pureftpd.pdb")
    CONFIG_DEFAULT_VALUE+=(['PureDB']="/etc/pureftpd.pdb")
}

function manualConfigPureFtp() {
    echo "Note: this not contain every parameter, just some i think it is useful. If you want know more, can read ${PURE_FTP_CONFIG_ROOT_PATH}/${PURE_FTP_CONFIG_NAMR}${BACKUP_FILE_SUFFIX}"

    for name in "${!CONFIG_DETAIL[@]}"; do
        echo "${CONFIG_DETAIL[${name}]}"
        read -r -p "Do you want to config by yourself? (y/n)? defult no!" confim
        confim=${confim:-no}
        if [[ ! "$confim" =~ y|Y ]]; then
            if [[ ${CONFIG_DEFAULT_VALUE[${name}]} ]]; then
                echo "configing ${name}, and the value is ${CONFIG_DEFAULT_VALUE[$name]}"
                echo "${CONFIG_DEFAULT_VALUE[$name]}" > ${PURE_FTP_PARAMETER_CONFIG_DIR}/"${name}"
            fi
        else
            read -r -p "Please input correct value" value
            echo "${value}" >${PURE_FTP_PARAMETER_CONFIG_DIR}/"${name}"
        fi
    done
}

function autoConfigPureFtp() {
    for name in "${!CONFIG_DETAIL[@]}"; do
        if [[ ${CONFIG_DEFAULT_VALUE[${name}]} ]]; then
            echo "configing ${name}, and the value is ${CONFIG_DEFAULT_VALUE[${name}]}"
            echo "${CONFIG_DEFAULT_VALUE[${name}]}" >${PURE_FTP_PARAMETER_CONFIG_DIR}/"${name}"
        fi
    done
}

function startPureFtpService() {
    systemctl enable pure-ftpd
    systemctl restart pure-ftpd
    systemctl status pure-ftpd
}

function checkExistngConfig() {
    if [[ -f ${PURE_FTP_CONFIG_ROOT_PATH}${PURE_FTP_CONFIG_NAMR}${BACKUP_FILE_SUFFIX} ]]; then
        read -r -p "You has been run this script already, do you want to run it anyway ?" confim
        if [[ ! "$confim" =~ y|Y ]]; then
            exit 1
        fi
    fi
}

function main() {
    echo "chinking os ..."
    checkOs
    checkRoot
    checkExistngConfig
    installDependents

    backupFtpDefaultConfig
    setConfigDetail

    read -r -p "Do you want to config pure-ftp by yourself? (y/n)" confim
    if [[ ! "$confim" =~ y|Y ]]; then
        autoConfigPureFtp
    else
        manualConfigPureFtp
    fi
    startPureFtpService
    echo "Congratulations config done!"
    exit 0
}

main
