#kvm qemu and tap, how do they works along?
kvm is not the key, the key is qemu
qemu is trying to emulate a network adapt, and qemu is a user space process and we should create a tap device, which in the 
kernel's eye is a driver;but as qemu sees it, it is just a simple file-fd;
so what happens when a virtual machine is trying to send a packet? Remember, the qemu is the emulatied NIC. So the qemu has to w
write something to the fd with syscall open().
However, in the kernel, the tap device is now receiving a packet.
that's the same when kernel send a packet to the tap. 
