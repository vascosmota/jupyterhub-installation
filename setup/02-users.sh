#!/bin/bash

# Add lecturers group
addgroup sysadmin

# Add lecturer users
while IFS=, read NAME PW; do
    echo "Creating system owner $NAME"
    if [ -z $PW ]; then
        useradd -s "/bin/bash" -m -N -g users -G sudo,adm,sysadmin $NAME
    else
        useradd -s "/bin/bash" -m -N -g users -G sudo,adm,sysadmin -p "$PW" $NAME
    fi
done < <(egrep -v '^#' lecturers.list)

# Add some admin users, add them to SSHD allowed list
ADMINS=`tr "\n" " " < admins.list`
echo "Administrators with SSH access: $ADMINS"
echo "AllowUsers $ADMINS" >> /etc/ssh/sshd_config
systemctl reload ssh.service

# Add regular users
while IFS=, read NAME PW; do
    echo "Creating user $NAME"
    if [ -z $PW ]; then
        useradd -s "/bin/bash" -m -N -g users $NAME
    else
        useradd -s "/bin/bash" -m -N -g users -p "$PW" $NAME
    fi
done < <(egrep -v '^#' students.list)

# Create fontconfig-cache so that the first execution of cells
# don't take time with some ugly warning messages.
echo "Creating fontconfig cache in HOME folders..."
for u in $(ls /home/); do
  sudo -H -u $u fc-cache
done
