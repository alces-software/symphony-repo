# Symphony4 director installer scripts

## VM

- start from a base centos7 qcow (create using oz centos 7) templates
- create additional repo datadisks
```
/usr/bin/qemu-img create -f qcow2 -o preallocation=metadata /opt/vm/symphony-repo-pulp.qcow2 80G
/usr/bin/qemu-img create -f qcow2 -o preallocation=metadata /opt/vm/symphony-repo-mongo.qcow2 80G
```
- create config drive using included script and content, modify config variables eg:
  - hostname
  - clustername
  - passwords
  - ssh keys 
- use libvirt xml file included, modify to localtion of qcow and config iso
- modify bridges as required for the vm host
- boot machine, wait for eth4 to start against external bridge (may take a while as eth0 needs to fail DHCP first) ifconfig will be dumped to console during boot so watch the console immediately after starting to get the IP
- ssh to external IP, default symphony key is in Google Drive

## Stage 1,2,3 install scripts
- run staged installer scripts, reboot between each one eg:
``` curl https://raw.githubusercontent.com/alces-software/symphony-repo/master/install/bin/stage1.sh | /bin/bash -x```


