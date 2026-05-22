FROM debian:latest

RUN apt-get update && apt-get install -y \
    git curl php unzip openssh-client \
    && apt-get clean

RUN git clone --depth=1 https://github.com/AsHfIEXE/Cyphisher.git /opt/Cyphisher

WORKDIR /opt/Cyphisher

ENTRYPOINT ["bash", "Cyphisher.sh"]
