FROM gcr.io/cloudshell-images/cloudshell:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -qq update && apt -qq install -y curl git sudo gpg apt-utils
COPY init.sh /tmp
RUN /tmp/init.sh