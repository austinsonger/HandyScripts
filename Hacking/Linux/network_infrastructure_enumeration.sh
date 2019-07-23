#!/bin/bash --login
# Run larger portscans in background while running smaller ones in parallel
usage() {
  echo "USAGE: ${0} <target_cidr> <interface>"
  exit 1
}

if [[ $# != 2 ]]; then
  usage
fi

target_cidr="${1}"
int="${2}"
cwd=$(pwd)
target_dir=`echo $target_cidr | sed 's/\//_/g'`

mkdir -p $target_dir
cd $target_dir

long_scan() {
  target_ip="${1}"
  int="${2}"

  if [[ ! -d $target_ip ]]; then 
    mkdir $target_ip
  fi
  
  if [[ ! -e 'tcp_default_open_nosvc_info.nmap' ]]; then
    nmap --open $target_ip -e $int -oN $target_ip/tcp_default_open_nosvc_info &
    nmap --open $target_ip -e $int -A -oN $target_ip/tcp_default_open_svc_info &
    nmap -A $target_ip -e $int -oN $target_ip/tcp_default_svc_info &
    nmap -sU -A $target_ip -e $int -oN $target_ip/udp_default_svc_info &
    nmap -A -sC $target_ip -e $int -oN $target_ip/tcp_default_svc_info_nse &
    nmap -A -p 1-65535 -sC $target_ip -e $int -oN $target_ip/tcp_default_svc_info_65k_nse &
    nmap -A -p 1-65535 -sC -Pn $target_ip -e $int -oA $target_ip/tcp_default_svc_info_nse_no_host_discovery &
    #nmap -A -p 1-65535 --script all -Pn $target_ip -e $int -oA $target_ip/tcp_default_svc_info_ALL_nse_no_host_discovery &
  else
    echo 'INFO: Already Scannning/Scanned this Target'
  fi
}

# FTP
recon_ftp() {
  target_ip="${1}"
  port="${2}"
 
  nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_ftp_nse"
}

nmap -p 21 --open $target_cidr -e $int -oN tcp_21_ftp
ls /usr/share/nmap/scripts/ | grep ftp >> tcp_21_ftp
grep "Nmap scan report for" tcp_21_ftp | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_ftp $ip 21
done

# SSH
recon_ssh() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_ssh_nse"
}

nmap -p 22 --open $target_cidr -e $int -oN tcp_22_ssh
ls /usr/share/nmap/scripts/ | grep ssh >> tcp_22_ssh
grep "Nmap scan report for" tcp_22_ssh | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_ssh $ip 22
done

# Telnet
recon_telnet() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_telnet_nse"
}

nmap -p 23 --open $target_cidr -e $int -oN tcp_23_telnet
ls /usr/share/nmap/scripts/ | grep telnet >> tcp_23_telnet
grep "Nmap scan report for" tcp_23_telnet | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_telnet $ip 23
done

# SMTP
recon_smtp() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_smtp_nse"
 # /bin/bash --login -c "smtp-user-enum -U <wordlist> -t $target_ip > '${target_ip}/tcp_${port}_smtp-user-enum' 2>&1" &
}

nmap -p 25 --open $target_cidr -e $int -oN tcp_25_smtp
ls /usr/share/nmap/scripts/ | grep smtp >> tcp_25_smtp
grep "Nmap scan report for" tcp_25_smtp | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_smtp $ip 25
done

# DNS
recon_dns() {
 target_ip="${1}"
 port="${2}"
 
 nmap -sU -p $port -sC $target_ip -e $int -oN "${target_ip}/udp_${port}_dns_nse"
 # Get domainname(s) and attempt zone transfer
 # host -al <domain> $target_ip
}

nmap -sU -p 53 --open $target_cidr -e $int -oN udp_53_dns
ls /usr/share/nmap/scripts/ | grep dns >> udp_53_dns
grep "Nmap scan report for" udp_53_dns | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_dns $ip 53
done

# HTTP
recon_http() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_http_nse"
 if [[ $port != '80' || $port != '443' ]]; then
   /bin/bash --login -c "nikto -host 'http://${target_ip}:${port}' -C all > '${target_ip}/${port}-nikto.txt' 2>&1" &
   /bin/bash --login -c "dirb 'http://${target_ip}:${port}' -o '${target_ip}/$port-dirb.txt'" &
 else
   if [[ $port == '80' ]]; then
     /bin/bash --login -c "nikto -host 'http://${target_ip}' -C all > $target_ip/$port-nikto.txt 2>&1" &
     /bin/bash --login -c "dirb 'http://${target_ip}' -o '${target_ip}/$port-dirb.txt'" &
   else
     /bin/bash --login -c "nikto -host 'https://${target_ip}' -C all > $target_ip/$port-nikto.txt 2>&1" &
     /bin/bash --login -c "dirb 'https://${target_ip}' -o '${target_ip}/$port-dirb.txt'" &
   fi
 fi
}

nmap -p 80 --open $target_cidr -e $int -oN tcp_80_http
ls /usr/share/nmap/scripts/ | grep http >> tcp_80_http
grep "Nmap scan report for" tcp_80_http | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 80
done

# POP3
recon_pop3() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_pop3_nse"
}

nmap -p 110 --open $target_cidr -e $int -oN tcp_110_pop3
ls /usr/share/nmap/scripts/ | grep pop3 tcp_110_pop3
grep "Nmap scan report for" tcp_110_pop3 | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_pop3 $ip 110
done

# IMAP
recon_imap() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_imap_nse"
}

nmap -p 143 --open $target_cidr -e $int -oN tcp_143_imap
ls /usr/share/nmap/scripts/ | grep imap tcp_143_imap
grep "Nmap scan report for" tcp_143_imap | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_imap $ip 143
done

# RPC
recon_rpc() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_rpc_nse"
}

nmap -p 135 --open $target_cidr -e $int -oN tcp_135_rpc
ls /usr/share/nmap/scripts/ | grep rpc >> tcp_135_rpc
grep "Nmap scan report for" tcp_135_rpc | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_rpc $ip 135
done

# SNMP
recon_snmp() {
 target_ip="${1}"
 port="${2}"
 
 nmap -sU -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_snmp_nse"
 /bin/bash --login -c "snmpwalk -c public -v1 ${target_ip} > '${target_ip}/tcp_${port}_snmpwalk' 2>&1" &
}

nmap -sU -p 161 --open $target_cidr -e $int -oN udp_161_snmp
ls /usr/share/nmap/scripts/ | grep snmp >> udp_161_snmp
grep "Nmap scan report for" udp_161_snmp | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_snmp $ip 161
done

# LDAP/LDAPS
recon_ldap() {
 target_ip="${1}"
 port="${2}"
 
 if [[ $port == '389' ]]; then
   nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_ldap_nse"
 else
   nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_ldaps_nse"
 fi
}

nmap -p 389 --open $target_cidr -e $int -oN tcp_389_ldap
ls /usr/share/nmap/scripts/ | grep ldap >> tcp_389_ldap
grep "Nmap scan report for" tcp_389_ldap | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_ldap $ip 389
done

# HTTPS
nmap -p 443 --open $target_cidr -e $int -oN tcp_443_https
ls /usr/share/nmap/scripts/ | grep http >> tcp_443_https
grep "Nmap scan report for" tcp_443_https | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 443
done

# SMB
recon_smb() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_smb_nse"
 /bin/bash --login -c "enum4linux $target_ip > '${target_ip}/tcp_${port}_enum4linux' 2>&1" &
}

nmap -p 445 --open $target_cidr -e $int -oN tcp_445_smb
ls /usr/share/nmap/scripts/ | grep smb >> tcp_445_smb
grep "Nmap scan report for" tcp_445_smb | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_smb $ip 445
done

# LDAPS
nmap -p 636 --open $target_cidr -e $int -oN tcp_636_ldaps
ls /usr/share/nmap/scripts/ | grep ldap >> tcp_636_ldaps
grep "Nmap scan report for" tcp_636_ldaps | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_ldap $ip 636
done

# MSSQL
recon_mssql() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_mssql_nse"
}

nmap -p 1433 --open $target_cidr -e $int -oN tcp_1433_mssql
ls /usr/share/nmap/scripts/ | grep mysql >> tcp_1433_mssql
grep "Nmap scan report for" tcp_1433_mssql | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_mssql $ip 1433
done

# MySQL
recon_myqsl() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_mysql_nse"
}

nmap -p 3306 --open $target_cidr -e $int -oN tcp_3306_mysql
ls /usr/share/nmap/scripts/ | grep mysql >> tcp_3306_mysql
grep "Nmap scan report for" tcp_3306_mysql | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_mysql $ip 3306
done

# RDP
recon_rdp() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_rdp_nse"
 # rdesktop $target_ip:$port
 # Grab window ID
 # xwininfo -root -children | grep rdesktop
 # Screenshot window based upon retrieved window ID
 # import -window $window_id "${target_ip}/tcp_${port}_rdp.png"
}

nmap -p 3389 --open $target_cidr -e $int -oN tcp_3389_rdp
ls /usr/share/nmap/scripts/ | grep "^rdp" >> tcp_3389_rdp
grep "Nmap scan report for" tcp_3389_rdp | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_rdp $ip 3389
done

# Postgres
recon_postgres() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_postgres_nse"
}

nmap -p 5432 --open $target_cidr -e $int -oN tcp_5432_postgres
ls /usr/share/nmap/scripts/ | grep pg >> tcp_5432_postgres
grep "Nmap scan report for" tcp_5432_postgres | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_postgres $ip 5432
done

# ALT HTTP
nmap -p 8000 --open $target_cidr -e $int -oN tcp_8000_http_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_8000_http_alt
grep "Nmap scan report for" tcp_8000_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 8000
done

# ALT HTTP
nmap -p 8080 --open $target_cidr -e $int -oN tcp_8080_http_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_8080_http_alt
grep "Nmap scan report for" tcp_8080_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 8080
done

# ALT HTTP
nmap -p 8443 --open $target_cidr -e $int -oN tcp_8443_https_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_8443_https_alt
grep "Nmap scan report for" tcp_8443_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 8443
done

# ALT HTTP
nmap -p 8888 --open $target_cidr -e $int -oN tcp_8888_http_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_8888_http_alt
grep "Nmap scan report for" tcp_8888_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 8888
done

# ALT HTTP
nmap -p 9000 --open $target_cidr -e $int -oN tcp_9000_http_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_9000_http_alt
grep "Nmap scan report for" tcp_9000_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 9000
done

# ALT HTTP
nmap -p 9999 --open $target_cidr -e $int -oN tcp_9999_http_alt
ls /usr/share/nmap/scripts/ | grep http >> tcp_9999_http_alt
grep "Nmap scan report for" tcp_9999_http_alt | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_http $ip 9999
done

# Webmin
recon_webmin() {
 target_ip="${1}"
 port="${2}"
 
 nmap -p $port -sC $target_ip -e $int -oN "${target_ip}/tcp_${port}_webmin_nse"
}

nmap -p 10000 --open $target_cidr -e $int -oN tcp_10000_webmin
grep "Nmap scan report for" tcp_10000_webmin | awk '{ print $NF }' | sed 's/[\(|\)]//g' | while read ip; do
  long_scan $ip $int
  recon_webmin $ip 10000
done
cd $cwd

echo 'REACHED THE END...WATCH SCANS TO WRAP UP!'