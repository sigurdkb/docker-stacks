ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER as prep


MAINTAINER Sigurd Brinch <sigurd.k.brinch@uia.no>

LABEL Software="Abaqus" \
      Version="2020"

RUN yum -y update --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs \
    freetype \
    ksh \
    libjpeg \
    libstdc++ \
    libgomp \
    perl \
    python3 \
    python3-pip \
    redhat-lsb-core \
    which && \
    yum clean all

FROM prep as installer

ADD ./abaqus-install /abaqus-install/
ADD ./UserIntentions.xml /UserIntentions.xml

RUN ksh /abaqus-install/1/StartTUI.sh --silent \
        /UserIntentions.xml \
        --xmlreport /tmp/abaqusinstall.xml \
        ; EXIT=$? && cat /tmp/abaqusinstall.xml && test $EXIT -eq 0

FROM prep

COPY --from=installer /var/DassaultSystemes/SIMULIA /var/DassaultSystemes/SIMULIA
COPY --from=installer /usr/SIMULIA /usr/SIMULIA

# Add to path
RUN echo "export PATH=$PATH:/var/DassaultSystemes/SIMULIA/Commands" | tee --append /etc/profile.d/local.sh

# Prepare for notebook use
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN python3 -m pip install --upgrade pip && \
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

