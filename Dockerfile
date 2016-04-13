FROM quay.io/nordstrom/baseimage-ubuntu:16.04
MAINTAINER Store Platform Team "invcldtm@nordstrom.com"

COPY cfssl cfssljson mkbundle multirootca cfssl-bundle cfssl-certinfo cfssl-newkey cfssl-scan /usr/bin/

ENTRYPOINT ["/usr/bin/cfssl"]
