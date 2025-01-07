## INSTALL K8S Scripts
### 1. 설치 테스트 환경 
``` 
OS : ubuntu 22.04
설치 환경 : 3 master 3node
 ```

### 2. 실행 환경 구성 
#### 2.1 ansible 설치
```
sudo apt update
sudo apt install software-properties-common
# ansible 저장소 등록
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible
```
#### 2.2 ansible 설치 확인
```
ansible --version
```
#### 2.3 inventory 구성 
```
#해당 내용을 /etc/ansible/hosts 등록 (IP는 설치 환경에 따라 변경필요)
[k8s]
192.168.100.100 ansible_ssh_user=k8s
192.168.100.101 ansible_ssh_user=k8s
192.168.100.102 ansible_ssh_user=k8s
192.168.100.80 ansible_ssh_user=k8s
192.168.100.81 ansible_ssh_user=k8s
192.168.100.82 ansible_ssh_user=k8s
[controller_salve]
192.168.100.101 ansible_ssh_user=k8s
192.168.100.102 ansible_ssh_user=k8s

[controller01]
192.168.100.100 ansible_ssh_user=k8s
[controller]
192.168.100.100 ansible_ssh_user=k8s
192.168.100.101 ansible_ssh_user=k8s
192.168.100.102 ansible_ssh_user=k8s

[worknode]
192.168.100.80 ansible_ssh_user=k8s
192.168.100.81 ansible_ssh_user=k8s
192.168.100.82 ansible_ssh_user=k8s
```
### 2.4 ansible key관련 에러 스킵 설정
```
#/etc/ansible/ansible.cfg
#아래 내용 추가
[defaults]
host_key_checking = False
```

### 3. sudo 권한 NOPWD 설정
```
- hosts: k8s
  become: yes
  tasks:
    - name: Allow passwordless sudo for the oneuser user
      lineinfile:
        path: /etc/sudoers
        state: present
        regexp: '^k8s' # 해당 부분을 사용 중인 일반 계정으로 변경
        line: 'oneuser ALL=(ALL) NOPASSWD:ALL'
        validate: 'visudo -cf %s'

      
      environment:
        EDITOR: "/usr/bin/vim" # Replace with your preferred editor

#  ansible-playbook startk8s/sudo.yaml -k -K
```

### 4. yaml 파일 Setup 
```
#startk8s/setup.yaml 수정

- hosts: controller01
  become: yes
  vars:
    controller01: "192.168.100.100" # cotrolplan01 IP 변경
    controller02: "192.168.100.101" # cotrolplan02 IP 변경
    controller03: "192.168.100.102" # cotrolplan03 IP 변경
    worknode01: "192.168.100.80" # worknode01 IP 변경
    worknode02: "192.168.100.81" # worknode02 IP 변경
    worknode03: "192.168.100.82" # worknode03 IP 변경
    vipaddr: "192.168.100.104" # VIP IP  변경
    interfacename: "192.168.100" # CIDR 대역 변경
    firstip: "192.168.100.83" # METALLB 할당 IP 변경
    endip: "192.168.100.85" # METALB 할당 IP 변경
  tasks:
    - name: haproxy.yaml ip setup
      shell: "{{ item }}"
      with_items:
        - "sed -i s/controller_01/{{ controller01 }}/g /tmp/ansible/startk8s/haproxy.yaml"
        - "sed -i s/controller_02/{{ controller02 }}/g /tmp/ansible/startk8s/haproxy.yaml"
        - "sed -i s/controller_03/{{ controller03 }}/g /tmp/ansible/startk8s/haproxy.yaml"
        - "sed -i 's/vipaddr/{{ vipaddr }}/g' /tmp/ansible/startk8s/haproxy.yaml"
        - "sed -i 's/INTERFACENAME/{{ interfacename }}/g' /tmp/ansible/startk8s/haproxy.yaml"
    - name: k8s.yaml ip setup
      shell: "{{ item }}"
      with_items:
        - "sed -i s/controller_01/{{ controller01 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/controller_02/{{ controller02 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/controller_03/{{ controller03 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i 's/vipaddr/{{ vipaddr }}/g' /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i 's/INTERFACENAME/{{ interfacename }}/g' /tmp/ansible/startk8s/k8s.yaml"
    - name: timezone.yaml ip setup
      shell: "{{ item }}"
      with_items:
        - "sed -i s/controller_01/{{ controller01 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/controller_02/{{ controller02 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/controller_03/{{ controller03 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/worknode_01/{{ worknode01 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/worknode_02/{{ worknode02 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/worknode_03/{{ worknode03 }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i 's/vipaddr/{{ vipaddr }}/g' /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i 's/INTERFACENAME/{{ interfacename }}/g' /tmp/ansible/startk8s/k8s.yaml"
    - name: metallb.yaml ip setup
      shell: "{{ item }}"
      with_items:
        - "sed -i s/firstIP/{{ firstip }}/g /tmp/ansible/startk8s/k8s.yaml"
        - "sed -i s/endIP/{{ endtip }}/g /tmp/ansible/startk8s/k8s.yaml"

#ansible-playbook startk8s/setup.yaml -k -K
       
```
### 5. 패키지 설치
```
ansible-playbook startk8s/pkg.yaml
```
### 6. timezone 설정
```
ansible-playbook startk8s/timezone.yaml
```
### 7. haproxy 설정
```
# 해당 세션은 metallb를 사용하기위해 keepalived + haproxy를 이용하여 
#VIP + LoadBalaner 설정을 진행하는 스크립트
ansible-playbook startk8s/haproxy.yaml
```
### 8. k8s 설치

```
ansible-playbook startk8s/k8s.yaml
```




