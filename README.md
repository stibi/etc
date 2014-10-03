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

## Ansible user

Stejný user pro všechny hosty

```
useradd -m -d /home/ansible -G wheel -s /bin/sh ansible
passwd ansible
mkdir /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 0700 /home/ansible/.ssh

Nakopírovat klíč přes mého usera
scp ~/.ssh/id_rsa.pub oblacek:~
chmod 600 ~/.ssh/authorized_keys

visudo a tam:
%wheel ALL=(ALL) NOPASSWD: ALL
```
