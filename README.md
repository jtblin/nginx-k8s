# nginx-k8s

Simple nginx reverse proxy for [kubernetes](http://kubernetes.io) which automagically serves all services
deployed on k8s based on domain name.

## Usage

    git clone git@github.com:jtblin/nginx-k8s.git

Update "mydomain.tld" in [default.conf](./default.conf) with your domain name: 

    "~^(www\.)?(?<sub_domain>.+)\.mydomain\.tld$";

Build the docker image:

    docker build -t myrepo/nginx-k8s .

Update the `PROXY_DOMAIN` environment variable in [nginx-k8s.yaml](./nginx-k8s.yaml) with the url of your k8s api 
server, the image name, and create the replication and service controller.

    docker push myrepo/nginx-k8s
    kubectl create -f nginx-k8s.yaml

Find the node ports (`NodePort`) of your `nginx-k8s` service:

    kubectl describe svc nginx

Create a load balancer including all kubernetes nodes (not the master) with a listener on the `http` node port.
You can terminate SSL on the ELB and add a healthcheck pointing to the `health` NodePort of the `nginx` service
for the path `/healthz`.

Deploy services to your kubernetes cluster, and set their domain name in your registar pointing to the 
load balancer created above. The subdomain part of the FQDN needs to be the same as the k8s service name. Profit!

## Specs, caveats and rationale

* The image is based on `alpine` linux so it is quite small (15Mb). 
* This works because services are accessible on k8s at `/api/v1/proxy/namespaces/default/services/<service-name>`.
* This config will only work for the `default` namespace. If you want to use a different namespace, update accordingly.
* This only works for services that expose only one port. If you need to expose more ports, just create more services.
* The overhead of going through the kube proxy might not be suitable for production use.
* This was done in anger because of the limitations with the current `LoadBalancer` type in k8s.
* Requires DaemonSets extension (from v1.1): http://kubernetes.io/v1.1/docs/admin/daemons.html
