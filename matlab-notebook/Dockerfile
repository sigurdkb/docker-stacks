# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER as prebuilder

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install OS dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
    ca-certificates \
    libasound2 \
    libatk1.0-0 \
    libavcodec-extra57 \
    libavformat57 \
    libc6 \
    libcairo-gobject2 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libfontconfig1 \
    libgdk-pixbuf2.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpam0g \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpython2.7 \
    libpython3.6 \
    libpython3.7 \
    libselinux1 \
    libsm6 \
    libsndfile1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxft2 \
    libxi6 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxt6 \
    libxtst6 \
    libxxf86vm1 \
    locales \
    locales-all \
    procps \
    sudo \
    xkb-data \
    zlib1g \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# To avoid inadvertantly polluting the / directory, use root's home directory 
# while running MATLAB.
WORKDIR /root

#### Install MATLAB in a multi-build style ####
FROM prebuilder as middle-stage

######
# Create a self-contained MATLAB installer using these instructions:
#
# https://www.mathworks.com/help/install/ug/download-only.html
#
# You must be an administrator on your license to complete this workflow
# You can run the installer on any platform to create a self-contained MATLAB installer
# When creating the installer, on the "Folder and Platform Selection" screen, select "Linux (64-bit)"
#
# Put the installer in a directory called matlab-install
# Move that matlab-install folder to be in the same folder as this Dockerfile
######

# Add MATLAB installer to the image
ADD matlab-install /matlab-install/

# Copy the file matlab-install/installer_input.txt into the same folder as the 
# Dockerfile. The edit this file to specify what you want to install. NOTE that 
# at a minimum you will need to have changed the following set of parameters in 
# the file.
#   fileInstallationKey
#   agreeToLicense=yes
#   Uncommented products you want to install
ADD matlab_installer_input.txt /matlab_installer_input.txt

# Now install MATLAB (make sure that the install script is executable)
RUN cd /matlab-install && \
    chmod +x ./install && \
    ./install -mode silent \
        -inputFile /matlab_installer_input.txt \
        -outputFile /tmp/mlinstall.log \
        -destinationFolder /usr/local/MATLAB \
    ; EXIT=$? && cat /tmp/mlinstall.log && test $EXIT -eq 0

#### Build final container image ####
FROM prebuilder

COPY --from=middle-stage /usr/local/MATLAB /usr/local/MATLAB

# Soft link matlab into /usr/local/bin
RUN ln -s /usr/local/MATLAB/bin/matlab /usr/local/bin/matlab

# One of the following 2 ways of configuring the FlexLM server to use must be
# uncommented.

ARG LICENSE_SERVER
# Specify the host and port of the machine that serves the network licenses 
# if you want to bind in the license info as an environment variable. This 
# is the preferred option for licensing. It is either possible to build with 
# something like --build-arg LICENSE_SERVER=27000@MyServerName, alternatively
# you could specify the licens server directly using
#       ENV MLM_LICENSE_FILE=27000@flexlm-server-name
ENV MLM_LICENSE_FILE=$LICENSE_SERVER

# Alternatively you can put a license file (or license information) into the 
# container. You should fill this file out with the details of the license 
# server you want to use nd uncomment the following line.
# ADD network.lic /usr/local/MATLAB/licenses/


# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
WORKDIR /home/$NB_USER

# Add alias and fix permissions
RUN echo "alias matlab='matlab -nodisplay'" >> /home/$NB_USER/.bashrc && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
