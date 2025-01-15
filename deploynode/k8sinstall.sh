#!/bin/bash

echo "git Sync"
cd /deploy/ansible
git pull

sed -i s/192.168.110.201/$IPA/g /deploy/ansible/deploynode/envconvert.yaml
sed -i s/192.168.110.250/$VIP/g /deploy/ansible/deploynode/envconvert.yaml
sed -i s/ubuntu/$TURBOUSER/g /deploy/ansible/deploynode/envconvert.yaml

sed -i s/192.168.110.201/$IPA/g /deploy/ansible/setting/k8ssetting.yaml
sed -i s/192.168.110.250/$VIP/g /deploy/ansible/setting/k8ssetting.yaml
sed -i s/ubuntu/$TURBOUSER/g /deploy/ansible/setting/k8ssetting.yaml


sed -i s/192.168.110.201/$IPA/g /deploy/ansible/setting/k8ssetup.yaml
sed -i s/192.168.110.250/$VIP/g /deploy/ansible/setting/k8ssetup.yaml
sed -i s/ubuntu/$TURBOUSER/g /deploy/ansible/setting/k8ssetup.yaml


echo "envconvert"
ansible-playbook /deploy/ansible/deploynode/envconvert.yaml

echo "k8s node setting"
sshpass -p 'onepredict99!@' ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini  -u oneuser --ask-pass /deploy/ansible/setting/k8ssetting.yaml
cd /deploy/kubespray
sshpass -p 'onepredict99!@' ansible-playbook  -i /deploy/kubespray/inventory/onepredict/inventory.ini cluster.yml  --forks 90 -b --become-user root -u oneuser  -k
sshpass -p 'onepredict99!@' ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini  -u oneuser --ask-pass /deploy/ansible/setting/k8ssetup.yaml
