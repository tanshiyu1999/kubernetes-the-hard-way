Kubelet (A node)
- Also a data plane
- Any kubernetes resource, including the control panel.
- It is a agent process that runs on every node (which is a compute resource)
- Execute scheduler decisions by starting containers on its node


Kube-Proxy Kubernetes (Need to dig deeper in the future)
- A data plane component, runs ass a DaemonSet on every node
- Help kubernetes work at the networking level
- Runs as a daemon on every node in the cluster
    - A DAEMON: Background process that runs constantly (not attached to any terminal or what nots)
        - Usually start at boot and run indefinitely, not tied to terminal/session and survives when logged out
        - Just does it's job
        - Come from a physics term hehe
- What problem does it solve?
    - Pods are ephemeral, they get created & die, and get new IP constantly
    - A service will give us a stable virtual IP (clusterIP), but the pods can come and go
    - The kube proxy intercept the ClusterIP and forward it to the pod
- What kube proxy does
    - Watches the API server for service and endpoint objects
- There is more going on in the internals, but the above is the high level understanding.
    - Update packet forwarding rules: iptables /IPVS)
- SIDE
    - What is a ClusterIP (is  the virtual app addr assigned to a k8s service)

Kube controller manager Kubernetes
- Control plane component that runs the various controller loops that keep cluster's actual state converging towards the desired state
- It's basically running this on a loop: watch current state → compare to desired state → take action to fix any difference → repeat forever
- ^ Above is just one controller example, but many controllers are being ran and yea..

Kube scheduler Kubernetes
- Control plane component deicding which node a newly created pod should run (it does not do it, it makes the decision and writes it down)
- Problem it solves:
    - Pod initially has no node assigned, kube scheduler looks at all the nodes and pick the best one to run on
- It works via a loop... (this can research later)


Kube apiserver
- Only controller component that talks directly to etcd
- Only component everything else talks through
- every interaction in k8s cluster (kubectl apply [this shit sends a HTTP request lmao]), goes through the API server
- It's a REST API server at it's core sitting in front of the etcd database
- It's like the hub in the hub and spoke 

etcd
- Stores the data
- only likes to talk to API server

Data Plane vs Control PLane
- Control Plane: Decide things
- Data Plane: Execute / carry traffic
Component	Plane	Job
etcd	Control	stores state
API server	Control	gatekeeper to that state
scheduler	Control	decides where pods go
controller-manager	Control	decides corrections to reconcile state
kubelet	Data	executes — starts/stops containers on its node
kube-proxy	Data	executes — programs packet forwarding on its node

cloud-controller-manager — a separate controller-manager specifically for cloud-provider-specific logic (e.g., provisioning an AWS ELB when you create a LoadBalancer-type Service, or tagging EC2 instances as Nodes). This is what lets core Kubernetes stay cloud-agnostic — AWS/GCP/Azure-specific code lives here instead of being baked into the main controller-manager. Since you work with EKS, this is actually running in your clusters right now, just managed by AWS.
- Control PLane

Container runtime (one we haven't covered) — the actual thing that runs containers (containerd, CRI-O). kubelet doesn't run containers itself — it talks to the container runtime via a standard interface called the CRI (Container Runtime Interface) and tells it "start this container." This is a whole concept on its own if you want to go there.
- Data Plane