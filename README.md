## vision: a Docker + Kubernetes trouble-shooting swiss-army container


**Purpose:** Docker and Kubernetes network troubleshooting can become complex. With proper understanding of how Docker and Kubernetes networking works and the right set of tools, you can troubleshoot and resolve these networking issues. The `vision` container has a set of powerful networking tshooting tools that can be used to troubleshoot Docker networking issues. 

**Network Namespaces:** Before starting to use this tool, it's important to go over one key topic: **Network Namespaces**. Network namespaces provide isolation of the system resources associated with networking. Docker uses network and other type of namespaces (`pid`,`mount`,`user`..etc) to create an isolated environment for each container. Everything from interfaces, routes, and IPs is completely isolated within the network namespace of the container. 

Kubernetes also uses network namespaces. Kubelets creates a network namespace per pod where all containers in that pod share that same network namespace (eths,IP, tcp sockets...etc). This is a key difference between Docker containers and Kubernetes pods.

Cool thing about namespaces is that you can switch between them. You can enter a different container's network namespace, perform some troubleshooting on its network's stack with tools that aren't even installed on that container. Additionally, `vision` can be used to troubleshoot the host itself by using the host's network namespace. This allows you to perform any troubleshooting without installing any new packages directly on the host or your application's package. 

* **Container's Network Namespace:** If you're having networking issues with your application's container, you can launch `vision` with that container's network namespace like this:

    `$ docker run -it --net container:<container_name> michaelcheungdk/vision`

* **Host's Network Namespace:** If you think the networking issue is on the host itself, you can launch `vision` with that host's network namespace:

    `$ docker run -it --net host michaelcheungdk/vision`

* **Network's Network Namespace:** If you want to troubleshoot a Docker network, you can enter the network's namespace using `nsenter`. 

**Kubernetes**

If you want to spin up a throw away container for debugging.

`$ kubectl run tmp-shell --rm -i --tty --image michaelcheungdk/vision -- /bin/bash`

If you want to spin up a container on the host's network namespace.

`$ kubectl run tmp-shell --rm -i --tty --overrides='{"spec": {"hostNetwork": true}}'  --image michaelcheungdk/vision  -- /bin/bash`

If you want to debug a container with the same `network`  namespace for debugging.

`$ kubectl debug $podname -n $namespace  -it --copy-to=debugger --image=michaelcheungdk/vision -- /bin/bash`

**Network Problems** 

Many network issues could result in application performance degradation. Some of those issues could be related to the underlying networking infrastructure(underlay). Others could be related to misconfiguration at the host or Docker level. Let's take a look at common networking issues:

* latency
* routing 
* DNS resolution

To troubleshoot these issues, `vision` includes a set of powerful tools as recommended by this diagram. 

![](http://www.brendangregg.com/Perf/linux_observability_tools.png)


**Included Packages:** The following packages are included in `vision`. We'll go over some with some sample use-cases.

    bash
    bind-tools
    bridge-utils
    calicoctl
    curl
    drill
    etcdctl
    ethtool
    file
    fping
    grpcurl
    iftop
    iproute2
    ipset
    iputils
    ipvsadm
    jq
    mtr
    openssl
    strace
    tcpdump
    tcptraceroute
    telnet


Inspired by: [netshoot](https://github.com/nicolaka/netshoot)
