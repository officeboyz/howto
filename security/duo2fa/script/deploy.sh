#/bin/sh 
echo "copy repo"
sudo cp -f script/etc/yum.repos.d/duosecurity.repo /etc/yum.repos.d/
echo "update pub key"
sudo rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
echo "install duo app"
sudo yum  -y install duo_unix
echo "copy config"
sudo cp -rf script/etc/duo/pam_duo.conf /etc/duo/
sudo cp -rf script/etc/ssh/sshd_config.d/50-redhat.conf /etc/ssh/sshd_config.d/
sudo cp -rf script/pam.d/* /etc/pam.d/
