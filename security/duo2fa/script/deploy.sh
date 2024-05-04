#/bin/sh 
echo "copy repo"
cp -f script/etc/yum.repos.d/duosecurity.repo /etc/yum.repos.d/
echo "update pub key"
rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
echo "install duo app"
yum install duo_unix
echo "copy config"
cp -rf script/etc/duo/pam_duo.conf /etc/duo/
cp -rf script/etc/ssh/sshd_config.d/50-redhat.conf /etc/ssh/sshd_config.d/
cp -rf script/pam.d/* /etc/pam.d/
