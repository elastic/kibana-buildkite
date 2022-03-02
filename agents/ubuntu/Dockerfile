FROM ubuntu:latest

RUN apt update && apt install -y python3-pip
WORKDIR /root
COPY ansible/requirements.txt .
RUN pip install -r requirements.txt

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt install -y curl software-properties-common && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" && \
  apt-get update && \
  apt-get install -y vault

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && \
  apt-get install -y packer

RUN setcap cap_ipc_lock= /usr/bin/vault

WORKDIR /app
