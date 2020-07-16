# Trickster Demo

*Based on the original [Trickster Demo (Docker Compose)](https://github.com/tricksterproxy/trickster/tree/master/deploy/trickster-demo) example.*

Trickster is a fully-featured HTTP Reverse Proxy Cache for HTTP applications like static file servers and web API's.

Trickster dramatically improves dashboard chart rendering times for end users by eliminating redundant computations on the TSDBs it fronts. In short, Trickster makes read-heavy Dashboard/TSDB environments, as well as those with highly-cardinalized datasets, significantly more performant and scalable.

## Getting Starting

In order to start entire infrastructure using Docker, you have to build images by executing

```
 $ make build-services
```

from a project root.

After starting services it takes a while for `API Gateway` to be in sync with service registry, so don't be scared of initial Zuul timeouts.

*NOTE: Under MacOSX or Windows, make sure that the Docker VM has enough memory to run the microservices. The default settings
are usually not enough and make the `docker-compose up` painfully slow.*

In its default configuration, Petclinic uses an in-memory database (HSQLDB) which gets populated at startup with data.

Once the services are ready, you can execute it using the Docker Compose file. From the root of thr epository, execute:

```
 $ make up-services
```

Now, it's time to up the observability infrastructure:

```
 $ make up-metrics
```

At this point, you can select the Grafana that you want to test:

```
 $ make up-grafana-direct
 $ make up-grafana-fs
 $ make up-grafana-mem
 $ make up-grafana-redis
```

Time to play!

## Services

If everything goes well, you can access the following services at given location:

__Business services__

  * AngularJS frontend (API Gateway) - http://localhost:8080
  * Customers, Vets and Visits Services - random port, check Eureka Dashboard

__Infrastructure__

 * Discovery Server - http://localhost:8761
 * Config Server - http://localhost:8888
 * Admin Server (Spring Boot Admin) - http://localhost:9090

__Microservices management__

  * Hystrix Dashboard for Circuit Breaker pattern - http://localhost:7979 - On the home page is a form where you can enter the URL for an event stream to monitor, for example the `api-gateway` service running locally: `http://localhost:8080/actuator/hystrix.stream` or running into docker: `http://api-gateway:8080/actuator/hystrix.stream`

__Observability__

  * Zipkin - http://localhost:9411

__Grafana__

  * Grafana with direct connection - http://localhost:3001
  * Grafana through Trickster with memmory cache - http://localhost:3002
  * Grafana through Trickster with file system cache - http://localhost:3003
  * Grafana through Trickster with Redis cache - http://localhost:3004

### Load

 * [Artillery](https://artillery.io/) load generator for the Pet-Clinic. (To ensure that all services are up and running properly.)

## Interact with the Containers

You can then interact with each of the services on their exposed ports (as defined in Compose file), or by running

```
$ make status
$ docker logs $container_name
```

or

```
$ make status
$ docker attach $container_name
```
