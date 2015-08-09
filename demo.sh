
MYIP=`hostname -I | cut -f1 -d' '`

DNS=172.17.42.1

function banner {
	echo -------------------------------
	echo $*
	echo --------------
}

banner consul
docker run --name consul -d -h dev -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p $DNS:53:53 -p $DNS:53:53/udp progrium/consul -server -advertise $MYIP --bootstrap-expect 1

banner haproxy
docker run -d -e SERVICE_NAME=rest --name=rest --dns $DNS -p 80:80 -p 1936:1936 sirile/haproxy


banner registrator
docker run -d -v /var/run/docker.sock:/tmp/docker.sock -h registrator --name registrator gliderlabs/registrator consul://$MYIP:8500


banner 3 instances of demo app
echo "==: instance 1 :=="
docker run -d -e SERVICE_NAME=hello/v1 -e SERVICE_TAGS=rest -h hello1 --name hello1 -p :80 sirile/scala-boot-test
echo "==: instance 2 :=="
docker run -d -e SERVICE_NAME=hello/v1 -e SERVICE_TAGS=rest -h hello2 --name hello2 -p :80 sirile/scala-boot-test
echo "==: instance 3 :=="
docker run -d -e SERVICE_NAME=hello/v1 -e SERVICE_TAGS=rest -h hello3 --name hello3 -p :80 sirile/scala-boot-test

banner log dump from registrator
docker logs registrator

banner "done"
echo
echo Visit http://$MYIP:1936 for haproxy stats
echo 
echo or http://$MYIP/hello/v1 for exposed service
echo
