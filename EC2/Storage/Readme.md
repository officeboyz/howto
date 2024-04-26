How to make EBS volume aviable for use

1. Make new volume in AWS Ec2 volume with same region in AWS EC2 will be attached
2. Attach the volume to AWS EC2 want add.
Linux Version
3. Check disk already to attach with command lsbk
 example output :
[ec2-user@ip-172-xx-xx-xx ~]$ lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
nvme0n1       259:0    0   20G  0 disk
├─nvme0n1p1   259:1    0   20G  0 part /
├─nvme0n1p127 259:2    0    1M  0 part
└─nvme0n1p128 259:3    0   10M  0 part /boot/efi
nvme1n1       259:4    0  200G  0 disk
[ec2-user@ip-172-xx-xx-xx ~]$
4. Formated volume with system need example xfs 

[ec2-user@ip-172-xx-xx-xx ~]$ sudo mkfs -t xfs /dev/nvme1n1
meta-data=/dev/nvme1n1           isize=512    agcount=16, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1
data     =                       bsize=4096   blocks=52428800, imaxpct=25
         =                       sunit=1      swidth=1 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=25600, version=2
         =                       sectsz=512   sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[ec2-user@ip-172-xx-xx-xx ~]$

5. Check volume was correct format :

[ec2-user@ip-172-xx-xx-xx ~]$ sudo file -s /dev/nvme1n1
/dev/nvme1n1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)
[ec2-user@ip-172-xx-xx-x ~]$

6. Mounting volume to folder .
[ec2-user@ip-172-xx-xx-xx ~]$ sudo mkdir /mnt/datamysql
[ec2-user@ip-172-xx-xx-xx ~]$ sudo chmod 777 /mnt/datamysql
[ec2-user@ip-172-xx-xx-xx ~]$ 
[ec2-user@ip-172-xx-xx-xx ~]$ sudo mount -t xfs /dev/nvme1n1 /mnt/datamysql/
[ec2-user@ip-172-xx-xx-xx ~]$ df -ah
Filesystem        Size  Used Avail Use% Mounted on
proc                 0     0     0    - /proc
sysfs                0     0     0    - /sys
devtmpfs          4.0M     0  4.0M   0% /dev
securityfs           0     0     0    - /sys/kernel/security
tmpfs             954M     0  954M   0% /dev/shm
devpts               0     0     0    - /dev/pts
tmpfs             382M  432K  382M   1% /run
cgroup2              0     0     0    - /sys/fs/cgroup
pstore               0     0     0    - /sys/fs/pstore
efivarfs             0     0     0    - /sys/firmware/efi/efivars
bpf                  0     0     0    - /sys/fs/bpf
/dev/nvme0n1p1     20G  1.6G   19G   8% /
selinuxfs            0     0     0    - /sys/fs/selinux
systemd-1            0     0     0    - /proc/sys/fs/binfmt_misc
mqueue               0     0     0    - /dev/mqueue
debugfs              0     0     0    - /sys/kernel/debug
hugetlbfs            0     0     0    - /dev/hugepages
tracefs              0     0     0    - /sys/kernel/tracing
tmpfs             954M     0  954M   0% /tmp
ramfs                0     0     0    - /run/credentials/systemd-sysctl.service
configfs             0     0     0    - /sys/kernel/config
fusectl              0     0     0    - /sys/fs/fuse/connections
ramfs                0     0     0    - /run/credentials/systemd-tmpfiles-setup-dev.service
systemd-1            -     -     -    - /boot/efi
ramfs                0     0     0    - /run/credentials/systemd-tmpfiles-setup.service
sunrpc               0     0     0    - /var/lib/nfs/rpc_pipefs
/dev/nvme0n1p128   10M  1.3M  8.7M  13% /boot/efi
tmpfs             191M     0  191M   0% /run/user/1001
/dev/nvme1n1      200G  1.5G  199G   1% /mnt/datamysql
[ec2-user@ip-172-xx-xx-xx ~]$ df -ah

7. Automatically mount an attached volume after reboot
   Update file /etc/fstab 
   example : 
[ec2-user@ip-172-xx-xx-x ~]$ cat /etc/fstab
#
UUID=900ed65c-6095-4ce3-8f14-60e443583ebd     /           xfs    defaults,noatime  1   1
UUID=9D5B-4A42        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
[ec2-user@ip-172-xx-xx-xx ~]$
[ec2-user@ip-172-xx-xx-xx ~]$ sudo blkid
/dev/nvme0n1p1: LABEL="/" UUID="900ed65c-6095-4ce3-8f14-60e443583ebd" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="Linux" PARTUUID="5bd60886-2c5e-4869-a458-8e38666e7b3b"
/dev/nvme0n1p128: SEC_TYPE="msdos" UUID="9D5B-4A42" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="EFI System Partition" PARTUUID="0801b364-a3b9-43d2-94ac-beacd5719880"
/dev/nvme0n1p127: PARTLABEL="BIOS Boot Partition" PARTUUID="bd2868f2-6508-4c89-8cb3-f766f48a9eb0"
/dev/nvme1n1: UUID="b6d2a52f-ed41-4fa9-b3f3-97f210731090" BLOCK_SIZE="512" TYPE="xfs"
[ec2-user@ip-172-xx-xx-xx ~]$ sudo cat /etc/fstab
#
UUID=900ed65c-6095-4ce3-8f14-60e443583ebd     /           xfs    defaults,noatime  1   1
UUID=9D5B-4A42        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
[ec2-user@ip-172-xx-xx-xx ~]$sudo vi /etc/fstab 
[ec2-user@ip-172-xx-xx-xx ~]$ sudo cat /etc/fstab
#
UUID=900ed65c-6095-4ce3-8f14-60e443583ebd     /           xfs    defaults,noatime  1   1
UUID=9D5B-4A42        /boot/efi       vfat    defaults,noatime,uid=0,gid=0,umask=0077,shortname=winnt,x-systemd.automount 0 2
UUID=b6d2a52f-ed41-4fa9-b3f3-97f210731090 /mnt//datamysql  xfs  defaults,nofail  0  2
[ec2-user@ip-172-xx-xx-xx ~]$
[ec2-user@ip-172-xx-xx-xx ~]$ df -ah
Filesystem        Size  Used Avail Use% Mounted on
proc                 0     0     0    - /proc
sysfs                0     0     0    - /sys
devtmpfs          4.0M     0  4.0M   0% /dev
securityfs           0     0     0    - /sys/kernel/security
tmpfs             954M     0  954M   0% /dev/shm
devpts               0     0     0    - /dev/pts
tmpfs             382M  436K  382M   1% /run
cgroup2              0     0     0    - /sys/fs/cgroup
pstore               0     0     0    - /sys/fs/pstore
efivarfs             0     0     0    - /sys/firmware/efi/efivars
bpf                  0     0     0    - /sys/fs/bpf
/dev/nvme0n1p1     20G  1.6G   19G   8% /
selinuxfs            0     0     0    - /sys/fs/selinux
systemd-1            -     -     -    - /proc/sys/fs/binfmt_misc
mqueue               0     0     0    - /dev/mqueue
debugfs              0     0     0    - /sys/kernel/debug
hugetlbfs            0     0     0    - /dev/hugepages
tracefs              0     0     0    - /sys/kernel/tracing
tmpfs             954M     0  954M   0% /tmp
ramfs                0     0     0    - /run/credentials/systemd-sysctl.service
configfs             0     0     0    - /sys/kernel/config
fusectl              0     0     0    - /sys/fs/fuse/connections
ramfs                0     0     0    - /run/credentials/systemd-tmpfiles-setup-dev.service
systemd-1            -     -     -    - /boot/efi
ramfs                0     0     0    - /run/credentials/systemd-tmpfiles-setup.service
sunrpc               0     0     0    - /var/lib/nfs/rpc_pipefs
/dev/nvme0n1p128   10M  1.3M  8.7M  13% /boot/efi
tmpfs             191M     0  191M   0% /run/user/1001
/dev/nvme1n1      200G  1.5G  199G   1% /mnt/datamysql
binfmt_misc          0     0     0    - /proc/sys/fs/binfmt_misc
[ec2-user@ip-172-xx-xx-xx ~]$

Test unmount and remount 
- umount 
[ec2-user@ip-172-xx-xx-xx ~]$ sudo umount -a
umount: /run/user/1001: target is busy.
umount: /: target is busy.
umount: /sys/fs/cgroup: target is busy.
umount: /run: target is busy.
umount: /dev: target is busy.
[ec2-user@ip-172-xx-xx-xx ~]$ df -ah
Filesystem      Size  Used Avail Use% Mounted on
proc               0     0     0    - /proc
sysfs              0     0     0    - /sys
devtmpfs        4.0M     0  4.0M   0% /dev
devpts             0     0     0    - /dev/pts
tmpfs           382M  436K  382M   1% /run
cgroup2            0     0     0    - /sys/fs/cgroup
/dev/nvme0n1p1   20G  1.6G   19G   8% /
selinuxfs          0     0     0    - /sys/fs/selinux
sunrpc             0     0     0    - /var/lib/nfs/rpc_pipefs
tmpfs           191M     0  191M   0% /run/user/1001
[ec2-user@ip-172-xx-xx-xx ~]$

Remount volume :

[ec2-user@ip-172-xx-xx-xx ~]$ sudo mount -a
[ec2-user@ip-172-xx-xx-xx ~]$ df -ah
Filesystem        Size  Used Avail Use% Mounted on
proc                 0     0     0    - /proc
sysfs                0     0     0    - /sys
devtmpfs          4.0M     0  4.0M   0% /dev
devpts               0     0     0    - /dev/pts
tmpfs             382M  436K  382M   1% /run
cgroup2              0     0     0    - /sys/fs/cgroup
/dev/nvme0n1p1     20G  1.6G   19G   8% /
selinuxfs            0     0     0    - /sys/fs/selinux
sunrpc               0     0     0    - /var/lib/nfs/rpc_pipefs
tmpfs             191M     0  191M   0% /run/user/1001
/dev/nvme0n1p128   10M  1.3M  8.7M  13% /boot/efi
/dev/nvme1n1      200G  1.5G  199G   1% /mnt/datamysql
[ec2-user@ip-172-xx-xx-xx ~]$

8. Restart
