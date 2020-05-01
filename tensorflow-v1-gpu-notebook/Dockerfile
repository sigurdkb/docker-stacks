# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for TensorRT
RUN apt-get update && apt-get install -yq --no-install-recommends \
    libnvinfer6=6.0.1-1+cuda10.0 \
    libnvinfer-dev=6.0.1-1+cuda10.0 \
    libnvinfer-plugin6=6.0.1-1+cuda10.0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

# Install Tensorflow
RUN pip install --quiet \
    'tensorflow-gpu==1.15.2' && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
