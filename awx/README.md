## 1. 기본설치 
### 1.1 kustomize 설치
#### mac
```
brew install kustomize
```
#### Linux
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```
### 2. awx 설치
vi kustomization.yaml
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.8.0
  - awx-demo.yaml

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.8.0

# Specify a custom namespace in which to install AWX
namespace: awx

```

### 3. awx-demo.yaml 생성
```
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: LoadBalancer # metallb가 설치 되어있지 않다면 NodePort로 변경
```

### 4. pv 생성 
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: awx-nfs-postgresspv
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /nvmevol  # NAS 서버의 경로
    server: nas.bestpath.co.kr  # NFS 주소
  persistentVolumeReclaimPolicy: Retain  # PV 재사용 정책 설정 (필요에 따라 변경 가능)
```

### 5. 설치 
kubectl apply 
