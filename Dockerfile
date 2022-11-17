# syntax=docker/dockerfile:1
FROM ubuntu:20.04
MAINTAINER Francesco Dimarcantonio <francesco@dimarcanton.io>

# Set BASH as Shell
SHELL ["/bin/bash", "-c"]

# Environment Variables
ARG USER=royler
ARG UID=1000 # Can be deleteddocke
# Magento Related Vars
ARG PROJECT_ID=XXXXXXXXXXXXXXXXXX
# Env variable 
ENV MAGENTO_CLOUD_CLI_TOKEN=XXXXXXXXXXXXXXXXXXX

# Update the system and install sudo 
RUN apt update && apt install sudo

# Security Check
RUN useradd -m -s /bin/bash -d /home/${USER}  ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    #chmod 0440 /etc/sudoers && \
    #chmod g+w /etc/passwd && \
    chown -R ${USER} /home/${USER}

# Switch User
USER ${USER}

# Install PHP
RUN  sudo apt install software-properties-common -y
RUN  sudo add-apt-repository ppa:ondrej/php
RUN  sudo apt update
RUN  sudo apt install -y php8.0 libapache2-mod-php8.0 php8.0-curl

# Install git + curl
RUN sudo apt install -y git curl wget

# Create folder for magento-cloud
RUN mkdir -p /home/${USER}/magento-cloud
RUN cd /home/${USER}/magento-cloud

# Install Magento CLI
RUN wget https://accounts.magento.cloud/cli/installer -O /home/${USER}/magento-cloud/installer

# Make executable
RUN sudo php /home/${USER}/magento-cloud/installer

# Give magento-cloud permission to user
USER root
RUN mv /root/.magento-cloud /home/${USER}/
RUN chown -R ${USER}:${USER} /home/${USER}/.magento-cloud
USER ${USER}

# Add magernto-cloud CLI to bash profile
ENV PATH="$PATH:$PATH:/home/${USER}/.magento-cloud/bin/"
RUN magento-cloud auth:api-token-login

