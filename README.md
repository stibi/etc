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

## Initial setup for Ansible ready machine

```
useradd -m -d /home/ansible -G wheel -s /bin/sh ansible
passwd ansible
mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh

Nakopírovat klíč přes mého usera
stibi@workstation$ ssh-copy-id ansible@192.168.2.243

pacman -S sudo
visudo a tam:
%wheel ALL=(ALL) NOPASSWD: ALL

pacman -S python2
```

## Ansible Vault

### Zakódovat existující soubor:
Řekne si to o heslo
```
ansible-vault encrypt roles/malina/vars/vault.yml
```

### Editace souboru ve Vaultu
```
ansible-vault edit roles/malina/vars/vault.yml
```

### Spuštění playbooku s Vaultem
Heslo mám uložené v _~/.ansible_vault_pass.txt_
```
ansible-playbook -i mymachines --limit=malina --vault-password-file=~/.ansible_vault_pass.txt main.yml
```

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
