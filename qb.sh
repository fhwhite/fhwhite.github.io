#!/bin/sh
sudo sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf
sudo sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
systemctl stop firewalld.service
systemctl disable firewalld.service

fhv=''
echo '
Select qBittorrent Version:
1.qBittorrent 4.1.9.1
2.qBittorrent 4.3.8'
read -p "Select：" num
case "$num" in
 1)
   fhv='4.1.9.1'
 ;;
 2)
   fhv='4.3.8'
 ;;
 *)
   echo 'please input {1|2}'
   exit;
esac

sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
if [ -f /etc/debian_version ]; then
   apt-get update -y
   apt-get install -y docker*
elif [ -f /etc/redhat-release ]; then
   yum install -y yum-utils
   yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   yum install -y docker-ce docker-ce-cli containerd.io
else
   echo "What version of Linux is this？"
   exit;
fi
systemctl start docker
systemctl enable docker
docker pull fhwhite/fhqb:$fhv
docker create --name=qbittorrent --network host -e UID=1000 -e GID=1000 -e UMASK=022 -v /root/pt/config:/config -v /:/Downloads --restart unless-stopped fhwhite/fhqb:$fhv
docker start qbittorrent
