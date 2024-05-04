Deploy Duo 2FA in Redhat 9.3 

## 1. update repo to  official 
sudo vi /etc/yum.repos.d/duosecurity.repo 
```bash
[duosecurity]
name=Duo Security Repository
baseurl=https://pkg.duosecurity.com/RedHat/$releasever/$basearch
enabled=1
gpgcheck=1
```
## 2. update repo 
```bash
$ rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
$ yum install duo_unix
```

## 3. edit file /etc/duo/pam_duo.conf

   Update base on data in duo dashboard

```bash
   ikey = xxx
   skey = xxx
   host = xxx
   pushinfo = yes
```

 ## 4. Since we will be using pam auth in ssh we need update some file
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
##    5. Restart sshd service and test it 

After enable duo 2fa with pam duo can't login root and you should have second account to manage access root 

Install duo step by step using script : 
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

```