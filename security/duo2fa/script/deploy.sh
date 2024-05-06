#/bin/bash
if [ `id -u` -ne 0 ]
  then echo Please run this script as root or using sudo!
  exit
  else 
     echo "copy repo" 
     /bin/cp -f script/etc/yum.repos.d/duosecurity.repo /etc/yum.repos.d/

     echo "update pub key"
     rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
     
     echo "install lib openssl dev"
     yum -y install openssl-devel pam-devel bzip2 

     echo "install duo app"
     yum  -y install duo_unix

     echo "copy config"
     #/bin/cp -rf script/etc/duo/pam_duo.conf /etc/duo/
     /bin/cp -rf duosecret.txt /etc/duo/pam_duo.conf
     /bin/cp -rf script/etc/ssh/sshd_config.d/50-redhat.conf /etc/ssh/sshd_config.d/
     /bin/cp -rf script/etc/pam.d/* /etc/pam.d/
fi
exit
