
MYIP=`hostname -I | cut -f1 -d' '`

DNS=172.17.42.1

function banner {
	echo -------------------------------
	echo $*
	echo --------------
}

if [ -z "`which docker`"  ]
then
	banner install docker
	wget -qO- https://get.docker.com/ | sh
fi

banner consul
docker run --name consul -d -h dev -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p $DNS:53:53 -p $DNS:53:53/udp progrium/consul -server -advertise $MYIP --bootstrap-expect 1

banner haproxy
docker run -d -e SERVICE_NAME=rest --name=rest --dns $DNS -p 80:80 -p 1936:1936 sirile/haproxy


banner registrator
docker run -d -v /var/run/docker.sock:/tmp/docker.sock -h registrator --name registrator gliderlabs/registrator consul://$MYIP:8500


echo 'docker run -d -e SERVICE_NAME=hello/v1 -e SERVICE_TAGS=rest -h hello$1 --name hello$1 -p :80 sirile/scala-boot-test' > /usr/bin/newnode
chmod +x /usr/bin/newnode


banner 3 instances of demo app
echo "==: instance 1 :=="
newnode 1
echo "==: instance 2 :=="
newnode 2
echo "==: instance 3 :=="
newnode 3

banner log dump from registrator
docker logs registrator

banner "done"
echo
echo Visit http://$MYIP:1936 for haproxy stats, and when any hosts in \'srvs_app7\' are green,
echo "then visit http://$MYIP/hello/v1 for exposed service (takes about 60 secs to come up on "
echo "digital ocean)"
echo
echo You can also add new nodes with \'newnode <id>\' where \'<id>\' is any identifier, it will
echo be appended to both the hostname and docker name so if id=\'foo\' then the hostname will
echo be \'hellofoo\' and so will the docker name. You can then try \'docker kill hellofoo\' to
echo get rid of it again, or equally \'docker kill hello2\' to get rid of the 2nd instance 
echo we already started.
