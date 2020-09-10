ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER as prep

MAINTAINER Sigurd Brinch <sigurd.k.brinch@uia.no>

LABEL Software="Ansys" \
      Version="2020"

RUN yum -y update --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs \
    compat-gcc-44 \
    compat-gcc-44-c++ \
    compat-libstdc++-33 \
    freetype \
    libjpeg-turbo \
    libpng12 \
    libglvnd-glx \
    libXp \
    libXext \
    openmotif \
    meld \
    motif \
    openssh-clients \
    redhat-lsb-core \
    vim \
    which \
    zlib \
    && yum clean all

FROM prep as installer

ADD ./installer /installer
ADD ./productfile /productfile

ARG LIC=2325:1055:piraya.uia.no

RUN /installer/INSTALL -silent \
    -licserverinfo $LIC \
    -productfile /productfile

FROM prep

COPY --from=installer /usr/ansys_inc /usr/ansys_inc

# Add to path
RUN echo "export PATH=$PATH:/usr/ansys_inc/v201/ansys/bin:/usr/ansys_inc/v201/fluent/bin" | tee --append /etc/profile.d/local.sh

# Prepare for notebook use
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN yum -y install --setopt=tsflags=nodocs \
    python3 \
    python3-pip \
    && yum clean all && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    notebook==6.0.3 \
    jupyterhub==1.1.0 \
    jupyterlab==2.0.1

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

EXPOSE 8888

USER $NB_UID
WORKDIR /home/$NB_USER

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
