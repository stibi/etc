Welcome to my `~/etc`!

## Jak použít playbook

### Spusť to všechno na všechny:
```
ansible-playbook -i mymachines main.yml
```

### Spusť jenom role pro konkrétního hosta

```
ansible-playbook -i mymachines --limit=workstation main.yml
```

Všude by měl být _NOPASSWD_ sudo user, ale kdyby náhodou, tak _-K_ parametr se zeptá na heslo přes spuštěním playbooku.

### Connection test

```
$ ansible -i mymachines malina -m ping      
192.168.2.134 | success >> {
    "changed": false, 
    "ping": "pong"
}
```

## Ansible user

Stejný user pro všechny hosty

```
useradd -m -d /home/ansible -G wheel -s /bin/sh ansible
passwd ansible
mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh

Nakopírovat klíč přes mého usera
(lokal) scp ~/.ssh/id_rsa.pub oblacek:~
(@ansible) touch ~/.ssh/authorized_keys
(@ansible) chmod 600 ~/.ssh/authorized_keys
(@ansible) cat id_rsa.pub >> ~/.ssh/authorized_keys

visudo a tam:
%wheel ALL=(ALL) NOPASSWD: ALL
```

## Ansible Vault

TODO

## Malina

Moje první RaspberryPi. OS: http://archlinuxarm.org/

https://wiki.archlinux.org/index.php/Raspberry
http://archlinuxarm.org/platforms/armv6/raspberry-pi

### Instalace

Postup na http://archlinuxarm.org/platforms/armv6/raspberry-pi funguje docela dobře.

Přihlášení pomocí root/root.

Hned po instalaci update systému:
```
pacman -Syu
pacman -S sudo
```

### Nastavení sítě

Používám [netctl](https://wiki.archlinux.org/index.php/netctl). Na malině obstará síť při prvním spuštění systemd-networkd, který získá adresu přes DHCP.
Zdá se, že oba dokáží běžet vedle sebe a možná bych mohl časem přejít komplet na systemd řešení. (TODO)

```
scp roles/malina/files/eth0 root@192.168.2.171:/etc/netctl/
```

```
[root@alarmpi ~]# netctl enable eth0
```

Reboot.
```
[root@alarmpi ~]# systemctl reboot
```

### Ansible

Vyrobit _ansible_ uživatele, viz výše, nastavit SSH klíč.

Nainstalovat python2:

```
[root@alarmpi ~]# pacman -S python2
```
