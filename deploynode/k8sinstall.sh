#!/bin/bash

echo "git Sync"
cd /deploy/ansible
git pull

echo "envconvert"
ansible-playbook /deploy/ansible/deploynode/envconvert.yaml

echo "k8s node setting"
sshpass -p '@whdgus123!' ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini  -u ubuntu --ask-pass /deploy/ansible/setting/k8ssetting.yaml
cd /deploy/kubespray
sshpass -p '@whdgus123!' ansible-playbook  -i /deploy/kubespray/inventory/onepredict/inventory.ini cluster.yml  --forks 90 -b --become-user root -u ubuntu  -k