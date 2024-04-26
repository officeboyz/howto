We assume you have already install amazon linux 2 / amazon linux 2023 OS or base or CentOS OS
1. Update  repo for make sure all update 
```bash
$ sudo yum update -y 
```
2. Install Mysql 5.7 package  
```bash
$ sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
```
3. Install gpg key for mysql 
```bash
$ sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 
```
4. Update repo for fecth latest 
```bash
$ sudo yum update 
```
5. Check version mysql 5.7 already in the repo 
```bash
$ sudo yum info mysql-community-server 
[ec2-user@ip-172-xx-xx-xx ~]$  sudo yum info mysql-community-server
Last metadata expiration check: 0:03:24 ago on Fri Apr 26 17:49:27 2024.
Available Packages
Name         : mysql-community-server
Version      : 5.7.44
Release      : 1.el7
Architecture : x86_64
Size         : 184 M
Source       : mysql-community-5.7.44-1.el7.src.rpm
Repository   : mysql57-community
Summary      : A very fast and reliable SQL database server
URL          : http://www.mysql.com/
License      : Copyright (c) 2000, 2023, Oracle and/or its affiliates. All rights reserved. Under GPLv2 license as shown in the Description field.
Description  : The MySQL(TM) software delivers a very fast, multi-threaded, multi-user,
             : and robust SQL (Structured Query Language) database server. MySQL Server
             : is intended for mission-critical, heavy-load production systems as well
             : as for embedding into mass-deployed software. MySQL is a trademark of
             : Oracle and/or its affiliates
             :
             : The MySQL software has Dual Licensing, which means you can use the MySQL
             : software free of charge under the GNU General Public License
             : (http://www.gnu.org/licenses/). You can also purchase commercial MySQL
             : licenses from Oracle and/or its affiliates if you do not wish to be bound by the terms of
             : the GPL. See the chapter "Licensing and Support" in the manual for
             : further info.
             :
             : The MySQL web site (http://www.mysql.com/) provides the latest news and
             : information about the MySQL software.  Also please see the documentation
             : and the manual for more information.
             :
             : This package includes the MySQL server binary as well as related utilities
             : to run and administer a MySQL server.

[ec2-user@ip-172-xx-xx-x ~]$
```
6. Install mysql 5.7 
```bash
$ sudo yum install mysql-community-server
[ec2-user@ip-172-xx-xx-xx ~]$  sudo yum install mysql-community-server
Last metadata expiration check: 0:06:02 ago on Fri Apr 26 17:49:27 2024.
Dependencies resolved.
============================================================================================================================================================================================================
 Package                                              Architecture                         Version                                                    Repository                                       Size
============================================================================================================================================================================================================
Installing:
 mysql-community-server                               x86_64                               5.7.44-1.el7                                               mysql57-community                               184 M
Installing dependencies:
 libxcrypt-compat                                     x86_64                               4.4.33-7.amzn2023                                          amazonlinux                                      92 k
 mysql-community-client                               x86_64                               5.7.44-1.el7                                               mysql57-community                                31 M
 mysql-community-common                               x86_64                               5.7.44-1.el7                                               mysql57-community                               313 k
 mysql-community-libs                                 x86_64                               5.7.44-1.el7                                               mysql57-community                               3.0 M
 ncurses-compat-libs                                  x86_64                               6.2-4.20200222.amzn2023.0.6                                amazonlinux                                     323 k

Transaction Summary
============================================================================================================================================================================================================
Install  6 Packages

Total download size: 219 M
Installed size: 931 M
Is this ok [y/N]: y
```
7. Enable service mysql 5.7  and start it. 
```bash
$ sudo systemctl enable mysqld 
$ sudo systemctl start mysqld 
```
8. Check autogenerate  password root in log 
```bash
$ sudo grep 'temporary password' /var/log/mysqld.log 
   A temporary password is generated for root@localhost: xxxx
```   
9. Update tune up for security    
```bash
$ sudo mysql_secure_installation 
```
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
```bash
mysql -u root -p -h localhost
```