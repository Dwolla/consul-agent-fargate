# Consul Agent in Fargate

I've been totally unable to get Consul Agents (up to version 1.2.4) to set the `bind_addr` value using `sockaddr` templates like 

```
{{ GetPrivateInterfaces | include "network" "10.0.0.0/8" | attr "address" }}
```

and AFAICT in Fargate, there are too many available IP addresses to let Consul pick one on its own. This image finds the IP address to bind to using the ECS Container Metadata Service, and then starts the Consul Agent with a `-bind` parameter set to that IP.
