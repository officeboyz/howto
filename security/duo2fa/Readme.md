Deploy Duo 2FA in Redhat 9.3 

### 1. update repo to  official 
sudo vi /etc/yum.repos.d/duosecurity.repo 
```bash
[duosecurity]
name=Duo Security Repository
baseurl=https://pkg.duosecurity.com/RedHat/$releasever/$basearch
enabled=1
gpgcheck=1
```
### 2. update repo 
```bash
$ rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
$ yum install duo_unix
```

### 3. edit file /etc/duo/pam_duo.conf

   Update base on data in duo dashboard 

```bash
   ikey = xxx
   skey = xxx
   host = xxx
   pushinfo = yes
```

 ### 4. Since we will be using pam auth in ssh we need update some file
    a.Edit /etc/ssh/ssh_config.d/50-redhat.conf

```bash   
        ChallengeResponseAuthentication yes
        UsePAM yes
        UseDNS no
        PubkeyAuthentication yes
        PasswordAuthentication no
        AuthenticationMethods publickey,keyboard-interactive
```

    b.edit pam configuration
       
      1. /etc/pam.d/system-auth 
              
         - before:   

```bash
            auth        required      pam_env.so
            auth        sufficient    pam_unix.so try_first_pass nullok
            auth        required      pam_deny.so
```

        - after 

```bash
            auth        required        pam_env.so
            #auth       sufficient      pam_unix.so try_first_pass nullok
            auth        requisite       pam_unix.so try_first_pass nullok
            auth        sufficient      pam_duo.so
            auth        required        pam_deny.so 
```

       2. SSH Public Key Authentication
           /etc/pam.d/sshd
         
          - before:
            
```bash
            auth       substack     password-auth
            auth       include      postlogin
```
          - after : 
            
```bash
            auth       required       pam_sepermit.so
            auth       required       pam_env.so
            #auth      substack       password-auth
            auth       sufficient     pam_duo.so
            auth       required       pam_deny.so
            auth       include        postlogin
```
###    5. Restart sshd service and test it 

After enable duo 2fa with pam duo can't login root and you should have second account to manage access root 

###    6. Install using script on redhta enterprise 9.3 

Install duo step by step using script make sure using **user root**  : 
```bash 

[root@localhost ~]# git clone -b develop https://github.com/officeboyz/howto.git
Cloning into 'howto'...
remote: Enumerating objects: 158, done.
remote: Counting objects: 100% (158/158), done.
remote: Compressing objects: 100% (87/87), done.
remote: Total 158 (delta 45), reused 135 (delta 22), pack-reused 0
Receiving objects: 100% (158/158), 18.03 KiB | 879.00 KiB/s, done.
Resolving deltas: 100% (45/45), done.
[root@localhost ~]# cd howto/security/duo2fa/
Readme.md  script/
[root@localhost ~]# cd howto/security/duo2fa/script/
[root@localhost script]#
[root@localhost script]# ls -lhat
total 4.0K
drwxr-xr-x. 3 root root  37 May  4 13:37 .
drwxr-xr-x. 3 root root  37 May  4 13:37 ..
-rwxr-xr-x. 1 root root 565 May  4 13:37 deploy.sh
drwxr-xr-x. 3 root root  17 May  4 13:37 script 
```
###     7.Edit file [script/duosecret.txt](script/duosecret.txt) with data from duo dashboard [ IKEY , SKEY , HOST] 

```bash
[root@localhost script]# vi duosecret.txt

[duo]
; Duo integration key
ikey = xxx
; Duo secret key
skey = xxxx
; Duo API host
host = xxxxx.duosecurity.com
; `failmode = safe` In the event of errors with this configuration file or connection to the Duo service
; this mode will allow login without 2FA.
; `failmode = secure` This mode will deny access in the above cases. Misconfigurations with this setting
; enabled may result in you being locked out of your system.
failmode = safe
; Send command for Duo Push authentication
pushinfo = yes
```

###     8.Running script deploy.sh  as ***root user***

```bash 
[root@localhost script]# ./deploy.sh
copy repo
update pub key
install duo app
Duo Security Repository                                                                                                                                                     1.3 kB/s | 1.7 kB     00:01
Dependencies resolved.
============================================================================================================================================================================================================
 Package                                         Architecture                                  Version                                             Repository                                          Size
============================================================================================================================================================================================================
Installing:
 duo_unix                                        x86_64                                        2.0.3-0.el9                                         duosecurity                                        404 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package

Total download size: 404 k
Installed size: 1.0 M
Downloading Packages:
duo_unix-2.0.3-0.el9.x86_64.rpm                                                                                                                                             226 kB/s | 404 kB     00:01
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                       225 kB/s | 404 kB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                    1/1
  Installing       : duo_unix-2.0.3-0.el9.x86_64                                                                                                                                                        1/1
  Running scriptlet: duo_unix-2.0.3-0.el9.x86_64                                                                                                                                                        1/1
  Verifying        : duo_unix-2.0.3-0.el9.x86_64                                                                                                                                                        1/1

Installed:
  duo_unix-2.0.3-0.el9.x86_64

Complete!
copy config
[root@localhost script]#   
[root@localhost script]# cat /etc/duo/pam_duo.conf

[duo]
; Duo integration key
ikey = xxx
; Duo secret key
skey = xxxx
; Duo API host
host = xxxxx.duosecurity.com
; `failmode = safe` In the event of errors with this configuration file or connection to the Duo service
; this mode will allow login without 2FA.
; `failmode = secure` This mode will deny access in the above cases. Misconfigurations with this setting
; enabled may result in you being locked out of your system.
failmode = safe
; Send command for Duo Push authentication
pushinfo = yes
[root@localhost script]#
[root@localhost script]# cat /etc/ssh/ssh_config.d/50-redhat.conf
# This system is following system-wide crypto policy. The changes to
# crypto properties (Ciphers, MACs, ...) will not have any effect in
# this or following included files. To override some configuration option,
# write it before this block or include it before this file.
# Please, see manual pages for update-crypto-policies(8) and sshd_config(5).
Include /etc/crypto-policies/back-ends/opensshserver.config

SyslogFacility AUTHPRIV

ChallengeResponseAuthentication yes

GSSAPIAuthentication yes
GSSAPICleanupCredentials no

UsePAM yes
UseDNS no

X11Forwarding yes

# It is recommended to use pam_motd in /etc/pam.d/sshd instead of PrintMotd,
# as it is more configurable and versatile than the built-in version.
PrintMotd no
AuthenticationMethods keyboard-interactive
[root@localhost script]#
[root@localhost script]# cat /etc/pam.d/system-auth
# Generated by authselect on Fri May  3 03:03:48 2024
# Do not modify this file manually.

auth        required                                     pam_env.so
auth        required                                     pam_faildelay.so delay=2000000
auth        sufficient                                   pam_fprintd.so
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        [default=1 ignore=ignore success=ok]         pam_localuser.so
#duo config
#auth        sufficient                                   pam_unix.so nullok
auth        requisite       pam_unix.so try_first_pass nullok
auth        sufficient      pam_duo.so
auth        [default=1 ignore=ignore success=ok]         pam_usertype.so isregular
auth        sufficient                                   pam_sss.so forward_pass
auth        required                                     pam_deny.so

account     required                                     pam_unix.so
account     sufficient                                   pam_localuser.so
account     sufficient                                   pam_usertype.so issystem
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required                                     pam_permit.so

password    requisite                                    pam_pwquality.so local_users_only
password    sufficient                                   pam_unix.so sha512 shadow nullok use_authtok
password    [success=1 default=ignore]                   pam_localuser.so
password    sufficient                                   pam_sss.so use_authtok
password    required                                     pam_deny.so

session     optional                                     pam_keyinit.so revoke
session     required                                     pam_limits.so
-session    optional                                     pam_systemd.so
session     [success=1 default=ignore]                   pam_succeed_if.so service in crond quiet use_uid
session     required                                     pam_unix.so
session     optional                                     pam_sss.so

[root@localhost script]# cat /etc/pam.d/ss
sshd              sssd-shadowutils
[root@localhost script]# cat /etc/pam.d/sshd
#%PAM-1.0
#duo config
#auth       substack     password-auth
auth       sufficient     pam_duo.so
auth       required       pam_deny.so
auth       include      postlogin
account    required     pam_sepermit.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    optional     pam_motd.so
session    include      password-auth
session    include      postlogin
[root@localhost script]#
[root@localhost script]# sudo systemctl restart sshd
```
###    9. Monitor log secure to make sure duo working ***(host/server must be can access internet )*** since need connect to duo push server api:
```bash
[root@localhost script]# tail -f /var/log/secure
May  4 13:25:44 localhost sudo[1654]: pam_unix(sudo:session): session opened for user root(uid=0) by utopia(uid=0)
May  4 13:25:44 localhost sudo[1654]: pam_unix(sudo:session): session closed for user root
May  4 13:43:33 localhost sudo[1942]: PAM unable to dlopen(/usr/lib64/security/pam_fprintd.so): /usr/lib64/security/pam_fprintd.so: cannot open shared object file: No such file or directory
May  4 13:43:33 localhost sudo[1942]: PAM adding faulty module: /usr/lib64/security/pam_fprintd.so
May  4 13:43:34 localhost sudo[1942]:    root : TTY=pts/0 ; PWD=/root/howto/security/duo2fa/script ; USER=root ; COMMAND=/bin/systemctl restart sshd
May  4 13:43:34 localhost sudo[1942]: pam_unix(sudo:session): session opened for user root(uid=0) by utopia(uid=0)
May  4 13:43:34 localhost sshd[846]: Received signal 15; terminating.
May  4 13:43:34 localhost sshd[1947]: Server listening on 0.0.0.0 port 22.
May  4 13:43:34 localhost sshd[1947]: Server listening on :: port 22.
May  4 13:43:34 localhost sudo[1942]: pam_unix(sudo:session): session closed for user root
May  4 13:43:59 localhost sshd[1949]: starting Duo Unix: PAM Duo
May  4 13:43:59 localhost sshd[1949]: Failsafe Duo login for 'utopia' from 192.168.2.61: Invalid ikey or skey
May  4 13:44:00 localhost sshd[1949]: Accepted password for utopia from 192.168.2.61 port 51919 ssh2
May  4 13:44:00 localhost sshd[1949]: pam_unix(sshd:session): session opened for user utopia(uid=1000) by (uid=0)

```
###     10. example ssh screen when duo not configure with valid data/connection internet:

```bash 
# ssh xxxx@xxx.xxx.xx.xx
xxxx@xxx.xxx.xx.xx's password:
Register this system with Red Hat Insights: insights-client --register
Create an account or view all your systems at https://red.ht/insights-dashboard
Last login: Sat May  4 13:44:00 2024 from xxx.xxx.xx.xx
[xxxx@localhost ~]$
```
###    11. example ssh screen when duo configure correctly : 

```bash 
 ✘ xxx@Apples-MacBook-Pro  ~  ssh xxxx@xxxxx
(xxxx@xx.xxx.xxx.xx) Duo two-factor login for xxxx

Enter a passcode or select one of the following options:

 1. Duo Push to +XX XXX-XXXX-80xx
 2. Duo Push to +XX XXX-XXXX-80xx
 3. SMS passcodes to +XX XXX-XXXX-80xx (next code starts with: 1)
 4. SMS passcodes to +XX XXX-XXXX-80xx

Passcode or option (1-4): 1
Success. Logging you in...
Last login: Sun Apr  7 17:32:57 2024 from xxx.xxx.xxx.xx
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

110 package(s) needed for security, out of 145 available
Run "sudo yum update" to apply all updates.
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[xxx@xxxxx ~]$
```
