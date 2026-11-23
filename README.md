# Consul Agent in Fargate

I've been totally unable to get Consul Agents (up to version 1.2.4) to set the `bind_addr` value using `sockaddr` templates like 

```
{{ GetPrivateInterfaces | include "network" "10.0.0.0/8" | attr "address" }}
```

and AFAICT in Fargate, there are too many available IP addresses to let Consul pick one on its own. This image finds the IP address to bind to using the ECS Container Metadata Service, and then starts the Consul Agent with a `-bind` parameter set to that IP.

## Usage

Pass the Dwolla environment (in lowercase) as the first value of the command array. Other values will be ignored.

## Building

The image is built from HashiCorp's official [`hashicorp/consul`](https://hub.docker.com/r/hashicorp/consul) image. Set the Consul version with the required `CONSUL_VERSION` build arg:

```
docker build --build-arg CONSUL_VERSION=2.1.0 .
```

The build fails if `CONSUL_VERSION` isn't set. `hashicorp/consul` publishes 1.8.x and later; older versions are only available from the deprecated `library/consul` image.
