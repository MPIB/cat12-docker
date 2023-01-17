FROM ubuntu:focal-20210416

MAINTAINER Jordi Huguet <jhuguet@barcelonabeta.org>

ARG DEBIAN_FRONTEND=noninteractive

LABEL description="CAT12 standalone docker image"
LABEL maintainer="jhuguet@barcelonabeta.org"

# set the working directory
WORKDIR /root

# install dependencies and prereqs
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get -yq install wget nano unzip libxext6 libxt6 moreutils \
 && apt-get clean

# install Matlab MCR at /opt/mcr
ENV MATLAB_VERSION R2017b
ENV MCR_VERSION v93
RUN mkdir /tmp/mcr_install \
 && mkdir /opt/mcr \
 && wget --progress=bar:force -P /tmp/mcr_install https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip \
 && unzip -q /tmp/mcr_install/MCR_R2017b_glnxa64_installer.zip -d /tmp/mcr_install \
 && /tmp/mcr_install/install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent
ENV MCRROOT /opt/mcr/${MCR_VERSION}

# install MCR/standalone version of SPM12 plus CAT12 at /opt/spm
ENV SPM_VERSION 12
ENV SPM_REVISION r7771
ENV MCR_INHIBIT_CTF_LOCK 1
ENV SPM_HTML_BROWSER 0
ENV CAT_VERSION 12.8.1
ENV CAT_REVISION r2042
ENV CAT_FULLVERSION CAT${CAT_VERSION}_${CAT_REVISION}
RUN wget --progress=bar:force -P /tmp http://www.neuro.uni-jena.de/cat12/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux.zip \
 && unzip -q /tmp/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux.zip -d /opt \
 && mv /opt/${CAT_FULLVERSION}_${MATLAB_VERSION}_MCR_Linux /opt/spm \
 && /opt/spm/run_spm12.sh ${MCRROOT} --version \
 && chmod +x /opt/spm/spm12 /opt/spm/*.sh \
 && chmod +x /opt/spm/spm12_mcr/home/gaser/gaser/spm/spm12/toolbox/cat12/CAT.glnx86/CAT_* \
 && rm -rf /tmp/*
RUN cp /opt/spm/spm12_mcr/home/gaser/gaser/spm/spm12/toolbox/cat12/cat_long_main.txt /opt/spm/spm12_mcr/home/gaser/gaser/spm/spm12/toolbox/cat12/cat_long_main.m
ENV PATH="${PATH}:/opt/spm/standalone"
ENV SPMROOT /opt/spm


ENTRYPOINT ["cat_standalone.sh"]
