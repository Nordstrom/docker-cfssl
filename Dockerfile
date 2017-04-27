FROM quay.io/nordstrom/baseimage-ubuntu:16.04
MAINTAINER Enterprise Kubernetes Team "techk8s@nordstrom.com"

COPY cfssl cfssljson mkbundle multirootca cfssl-bundle cfssl-certinfo cfssl-newkey cfssl-scan /usr/bin/

ENTRYPOINT ["/usr/bin/cfssl"]
