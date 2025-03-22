#!/bin/bash

echo "git Sync"
cd /deploy/ansible
git pull


sed -i s/192.168.110.201/$IPA/g /deploy/ansible/deploynode/envconvert.yaml
sed -i s/192.168.110.250/$VIP/g /deploy/ansible/deploynode/envconvert.yaml
sed -i s/ubuntu/$USER/g /deploy/ansible/deploynode/envconvert.yaml


sed -i s/192.168.110.201/$IPA/g /deploy/ansible/setting/k8ssetup.yaml
sed -i s/192.168.110.250/$VIP/g /deploy/ansible/setting/k8ssetup.yaml
sed -i s/ubuntu/$USER/g /deploy/ansible/setting/k8ssetup.yaml


export ANSIBLE_BECOME_PASS="$PW"
export ANSIBLE_PASSWORD="$PW"
echo "envconvert"
ansible-playbook /deploy/ansible/deploynode/envconvert.yaml

echo "k8s node setting"
ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini  /deploy/ansible/setting/k8ssetting.yaml  -u $USER -b --become-user root -k -K
cd /deploy/kubespray
ansible-playbook  -i /deploy/kubespray/inventory/onepredict/inventory.ini cluster.yml  --forks 90 -b --become-user root -u $TURBOUSER  -k 
ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini  -u $USER  -b --become-user root   /deploy/ansible/setting/k8ssetup.yaml -k
