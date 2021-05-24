###################################################
# Dockerfile to build annotator_utils
# Based on Ubuntu 18.04
###################################################

################# BASE IMAGE ######################
FROM ubuntu:18.04

################## LABEL ######################
LABEL MAINTAINER="VIREN AMIN"


################## INSTALLATION ####################
RUN mkdir /tmp/tools && mkdir /tmp/data

RUN apt-get update && apt-get install -y wget ca-certificates \
    gnupg2 python3-dev python3-pip 

RUN pip3 install --upgrade pip
RUN pip3 install pandas
RUN pip3 install cyvcf2

COPY variant_coverage_annotator.py /tmp/tools

WORKDIR /tmp/tools
