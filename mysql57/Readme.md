We assume you have already install amazon linux 2 / amazon linux 2023 OS or base or CentOS OS
1. Update  repo for make sure all update 
$ sudo yum update -y 
2. Install Mysql 5.7 package  
$ sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
3. Install gpg key for mysql 
$ sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 
4. Update repo for fecth latest 
$ sudo yum update 
5. Check version mysql 5.7 already in the repo 
$ sudo yum info mysql-community-server 
6. Install mysql 5.7 
$ sudo yum install mysql-community-server
7. Enable service mysql 5.7  and start it. 
$ sudo systemctl enable mysqld 
$ sudo systemctl start mysqld 
8. Check autogenerate  password root in log 
$ sudo grep 'temporary password' /var/log/mysqld.log 
   A temporary password is generated for root@localhost: xxxx
9. Update tune up for security    
$ sudo mysql_secure_installation 

Enter password for user root: [Enter current root password]
New password: [Enter a new root password]
Re-enter new password: [Re-Enter the new root password]
Estimated strength of the password: 100
Change the password for root ? ((Press y|Y for Yes, any other key for No) : n
Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
All done!

10. Test access 
mysql -u root -p