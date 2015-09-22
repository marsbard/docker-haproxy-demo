# docker-haproxy-demo


This is a demonstration of orchestrating docker containers with the help of consul service discovery.

It uses registrator to watch the docker environment for new containers.

When registrator finds a new container it contacts the consul container to add the containers capabilities.

Consul in turn knows which containers are needed to add to the haproxy and using consul-template will create a new haproxy configuration and upload it.

Haproxy provides a user facing endpoint that proxies all the containers in the backend. In production this would be a farm of two haproxy servers, for this demo the service is unavailable while the sole haproxy is cycled. 

Once you have run `demo.sh` you will have running the following containers:

  * consul
  * registrator
  * haproxy
  * sample service instances hello{1..3}
  

At the end of setup, you will see something like this (the IP is long gone, obviously)
```
-------------------------------
done
--------------

Visit http://188.166.85.252:1936 for haproxy stats, and when any hosts in srvs_app7 are green

then visit http://188.166.85.252/hello/v1 for exposed service

You can also add new nodes with 'newnode <id>' where '<id>' is any identifier, it will
be appended to both the hostname and docker name so if id='foo' then the hostname will
be 'hellofoo' and so will the docker name. You can then try 'docker kill hellofoo' to
get rid of it again, or equally 'docker kill hello2' to get rid of the 2nd instance
we already started.
```

So using that info you can review the haproxy stats and see when the servers come alive and watch how the exposed endpoint reacts. For its part it outputs the hostname as part of its content:
```
{"hostname":"hello3","time":1439143457013,"language":"Scala"}
```
