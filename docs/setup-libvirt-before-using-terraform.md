# Libvirt
## Installation
### Setup libvirt server using tcp for developing only
To work with libvirt remotedly, we must apply some workaround in orderto make 
libvirt to expose port to outside. At first, mask libvirt sockets except 
libvirtd-tcp.socket and libvirtd.socket. Then update file /etc/libvirtd.conf
to enable tcp by editing:
```
listen_tcp = 1
```

and disable tls by editing
```
listen_tls = 0
```

We also need to disable authentication for tcp with this configuration
```
auth_tcp = "none"
```

After that, we could enable libvirtd again to use tcp by command:
```
systemctl enable libvirtd-tcp.socket
```

On Ubuntu, there is an issue related to libvirtd can't generate appamor 
correctly and cause issue `Permission Deny` when starting the IaC at 
first glance. To overcome this, we must edit file /etc/libvirt/qemu.conf
```
security_driver = "none"
```
