# docker-haproxy-demo


This is a demonstration of orchestrating docker containers with the help of consul service discovery.

It uses registrator to watch the docker environment for new containers.

When registrator finds a new container it contacts the consul container to add the containers capabilities.

Consul in turn knows which containers are needed to add to the haproxy and using console-template will create a new haproxy configuration and upload it.

Haproxy provides a user facing endpoint that proxies all the containers in the backend.

Once you have run `demo.sh` you will have running the following containers:

  * consul
  * registrator
  * haproxy
  * sample service instances hello{1..3}
  
