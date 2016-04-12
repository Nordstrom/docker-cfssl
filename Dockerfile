FROM quay.io/nordstrom/baseimage-ubuntu:16.04
MAINTAINER Store Platform Team "invcldtm@nordstrom.com"

COPY cfssl mkbundle multirootca /usr/bin/

ENTRYPOINT ["/usr/bin/cfssl"]
