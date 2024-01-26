helm repo add harbor https://helm.goharbor.io
helm repo update
helm pull harbor/harbor
tar xvzf harbor-1.14.0.tgz
kubectl patch storageclasses storege-harbornfs -p '{"metadata": {"annotations":{"storageclass.kuberetes.io/is-default-class":"true"}}}'
helm install harbor -f values.yaml