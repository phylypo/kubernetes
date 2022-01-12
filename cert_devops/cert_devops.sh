az group create --name k8rg --location westus2
az aks create --resource-group k8rg --name myAKSCluster --node-count 1
az aks get-credentials --resource-group k8rg --name myAKSCluster
# test kubectl
kubectl get pod
kubectl get services


### install cert-manager 
# original
#curl -LO https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.yaml
kubectl apply --validate=false -f cert-manager.yaml
kubectl -n cert-manager get all

### create self-signed
kubectl create ns cert-manager-test
# original
#curl -o ss_issuer.yaml https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/cert-manager/selfsigned/issuer.yaml
kubectl apply -f ss_issuer.yaml

# original
#curl -o ss_certificate.yaml https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/cert-manager/selfsigned/certificate.yaml
kubectl apply -f ss_certificate.yaml

# verify
kubectl describe certificate -n cert-manager-test
kubectl get secrets -n cert-manager-test
# cleanup
kubectl delete ns cert-manager-test

### Create ingress-controller
kubectl create ns ingress-nginx

# original
#curl -o deploy-ingress-ctl.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx apply -f deploy-ingress-ctl.yaml

kubectl -n ingress-nginx get all

### Use let's encrypt issuer
# original
#curl -LO https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/cert-manager/cert-issuer-nginx-ingress.yaml
kubectl apply -f cert-issuer-nginx-ingress.yaml

kubectl describe clusterissuer letsencrypt-cluster-issuer

### deploy app for nginx to point to
# original
#curl -o deployment-app.yaml https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/deployments/deployment.yaml
kubectl apply -f deployment-app.yaml

# original
#curl -o service-app.yaml https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/services/service.yaml
kubectl apply -f service-app.yaml

kubectl get pods

### deploy an ingress route on port 80 to point to the example-service
# original
#curl -LO https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/cert-manager/ingress.yaml
#edit ingress with hostname
kubectl apply -f ingress.yaml

# should be able to browse and see hello world instead of nginx 404

### Create certificate from issuer
# original
#curl -LO https://raw.githubusercontent.com/marcel-dempers/docker-development-youtube-series/master/kubernetes/cert-manager/certificate.yaml
# vi the dns name
kubectl apply -f certificate.yaml

kubectl describe certificate example-app
## should see certificate issued
Events:
  Type    Reason     Age    From          Message
  ----    ------     ----   ----          -------
  Normal  Issuing    9m38s  cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  9m38s  cert-manager  Stored new private key in temporary Secret resource "example-app-lx9fw"
  Normal  Requested  9m38s  cert-manager  Created new CertificateRequest resource "example-app-hrdc7"
  Normal  Requested  29s    cert-manager  Created new CertificateRequest resource "example-app-8q7lf"
  Normal  Issuing    2s     cert-manager  The certificate has been successfully issued

kubectl get secret

NAME                  TYPE                                  DATA   AGE
default-token-pch9p   kubernetes.io/service-account-token   3      82m
example-app-tls       kubernetes.io/tls                     2      5m44s

### Browse to https in incognito
Should see the lock on the browser and the cert is signed by R3
