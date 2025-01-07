FROM ubuntu:22.04

# 필요한 패키지 설치
RUN mkdir /deploy
WORKDIR /deploy

RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        python3 \
        python3-pip \
        wget \
        vim \
        git \
        sshpass

RUN apt-get update && \
    apt-get install -y python3 python3-pip wget vim && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/wjswhdgus123/ansible.git

RUN apt-get update && \
    apt-get install -y git && \
    git clone -b v2.27.0 https://github.com/kubernetes-sigs/kubespray.git


# requirements.txt 설치
RUN pip install -r /deploy/kubespray/requirements.txt
RUN cp -a /deploy/kubespray/inventory/sample/ /deploy/kubespray/inventory/onepredict

# SSH 설정
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config


# SSH 서비스 실행
# 컨테이너가 실행될 때 SSH 데몬을 실행합니다.
CMD ["/usr/sbin/sshd", "-D"]