FROM ubuntu:lunar

RUN apt-get update && apt-get install -y --no-install-recommends \
ca-certificates \
binfmt-support \
curl \
gpg \
wget \
git \
make \
unzip \
golang-go \
qemu-user-static \
kpartx \
&& \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

WORKDIR /srcs
CMD make clean install image
