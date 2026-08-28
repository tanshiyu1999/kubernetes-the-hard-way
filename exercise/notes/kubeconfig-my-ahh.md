`https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/`

Every Context have a
- Namespace (optional)
- Cluster
- User

We can use openssl certs to configure the authentication with this.

That is all !


`kubeconfig file example`:
```
apiVersion: v1
kind: Config
clusters:
- name: qac-platform-prod
  cluster:
    server: https://prod-cluster-endpoint
- name: qac-platform-dev
  cluster:
    server: https://dev-cluster-endpoint
users:
- name: my-user
  user:
    exec: ...
contexts:
- name: prod
  context:
    cluster: qac-platform-prod
    user: my-user
    namespace: default
- name: dev
  context:
    cluster: qac-platform-dev
    user: my-user
current-context: prod
```

## Where does the cluster live?
```
No — this file doesn't live on the control plane at all, and the cluster doesn't "know" about it in any sense. This is a common point of confusion, so let's untangle it.

Where it lives: Purely on the client side — your laptop, a CI runner, wherever you're running kubectl from. The control plane has never seen this file and never will.

How the cluster "knows" who you are: It doesn't know anything from your kubeconfig — the kubeconfig is just local instructions telling your kubectl binary how to construct a request. When you run kubectl get pods --context=dev-frontend, here's what actually happens:

kubectl reads config-demo locally
It resolves dev-frontend → cluster development (server https://1.2.3.4) + user developer (cert/key files)
It opens a TLS connection to https://1.2.3.4, verifying the server's cert is signed by fake-ca-file (so you trust them)
It presents fake-cert-file/fake-key-file as client credentials in that TLS handshake (so they can authenticate you)
The API server on the control plane receives this HTTPS request, checks the client cert against its own trusted CA, extracts your identity from the cert (e.g. CN=developer), then checks RBAC rules to see if developer is allowed to do this action in the frontend namespace

So the "knowledge" lives on both ends independently:

Your side (kubeconfig): "here's the address to hit and here's my ID card"
Control plane side (its own CA + RBAC config, stored in etcd): "here's who I trust and what they're allowed to do"

The kubeconfig file is never transmitted to the cluster — only the actual cert/token material inside the TLS handshake is. Think of it like a hotel key card system: your keycard (kubeconfig) is something you carry; the door reader (API server) independently checks against the hotel's own database of valid cards — the two aren't the same object, they just have to agree.
```