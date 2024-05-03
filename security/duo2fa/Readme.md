Deploy Duo 2FA in Redhat 9.3 

1.update repo to  official 
sudo vi /etc/yum.repos.d/duosecurity.repo 
```bash
[duosecurity]
name=Duo Security Repository
baseurl=https://pkg.duosecurity.com/RedHat/$releasever/$basearch
enabled=1
gpgcheck=1
```
2. update repo 
```bash
$ rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
$ yum install duo_unix
```

3. edit file /etc/duo/pam_duo.conf
   Update base on data in duo dashboard
   ikey = xxx
   skey = xxx
   host = xxx
   pushinfo = yes

 4. Since we will be using pam auth in ssh we need update some file : 
    
    a. edit /etc/ssh/ssh_config.d/50-redhat.conf
     ```bash   
        ChallengeResponseAuthentication yes
        UsePAM yes
        UseDNS no
        PubkeyAuthentication yes
        PasswordAuthentication no
        AuthenticationMethods publickey,keyboard-interactive
      ```  
    b. edit pam configuration
       
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
    c. Restart sshd service and test it 
            