#!/bin/bash

echo "git Sync"
cd /deploy/ansible
git pull

echo "envconvert"
ansible-plabook /deploy/ansible/deploynode/envconvert.yaml

echo "k8s node setting"
sshpass -p '@whdgus123!' ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini -u ubuntu --ask-pass /deploy/ansible/setting/k8ssetting.yaml
sshpass -p '@whdgus123!' ansible-playbook -i /deploy/kubespray/inventory/onepredict/inventory.ini --forks 50 -b --become-user root  -u ubuntu --ask-pass /deploy/kubespray/cluster.yml
