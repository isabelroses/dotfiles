!#/bin/bash

read -p 'optimise?(y/n): ' userinp

if [ $userinp == 'y' ]
then
	systemctl stop docker
        systemctl stop cloudflared
        systemctl stop sshd
else
	systemctl start docker
        systemctl start cloudflared
        systemctl start sshd
fi
