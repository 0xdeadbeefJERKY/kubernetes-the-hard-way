#!/bin/bash

if ! command -v cfssl &> /dev/null
then
    echo "cfssl could not be found"
    exit
fi

cd ./pki

# CA certs
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Client and server certs
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

# Kubelet client certs
instances=`gcloud compute instances list --filter="name~'worker'" --format="table[no-heading](name)"`
for instance in $instances; do
  cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "New York",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "New York"
    }
  ]
}
EOF

  EXTERNAL_IP=`gcloud compute instances describe ${instance} \
    --format 'value(networkInterfaces[0].accessConfigs[0].natIP)'`

  INTERNAL_IP=`gcloud compute instances describe ${instance} \
    --format 'value(networkInterfaces[0].networkIP)'`

  cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
      -profile=kubernetes \
      ${instance}-csr.json | cfssljson -bare ${instance}
done

# Controller manager client cert
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

# Kube proxy client cert
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

# Scheduler client cert
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

# Kubernetes API server cert
KUBERNETES_PUBLIC_ADDRESS=`gcloud compute addresses describe k8s-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)'`

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cinstances=`gcloud compute instances list --filter="name~'controller'" --format="table[no-heading](name)"`
for instance in $cinstances; do 
  gcloud compute instances describe $instance --format 'table[no-heading](networkInterfaces[0].networkIP)' >> tmp.txt
done

CINTERNAL_IP=`sed -z 's/\n/,/g' tmp.txt`
rm tmp.txt

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,${CINTERNAL_IP},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

# Service accout key pair
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

# Distribute certs
for instance in $instances; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

for instance in $cinstances; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done