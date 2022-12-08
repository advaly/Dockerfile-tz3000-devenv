FROM debian:jessie
WORKDIR /root

# Enable i386 and install neccessary packages
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y --force-yes wget bzip2 make gcc u-boot-tools git vim libc6:i386 libstdc++6:i386 zlib1g:i386 kmod

# Install cross toolchain from Linaro
RUN wget "https://launchpad.net/linaro-toolchain-binaries/trunk/2012.10/+download/gcc-linaro-arm-linux-gnueabihf-4.7-2012.10-20121022_linux.tar.bz2"
RUN tar xvjf gcc-linaro-arm-linux-gnueabihf-4.7-2012.10-20121022_linux.tar.bz2 -C /opt/
RUN ln -s /opt/gcc-linaro-arm-linux-gnueabihf-4.7-2012.10-20121022_linux /opt/gcc-linaro-arm-linux-gnueabihf
RUN echo 'PATH=$PATH:/opt/gcc-linaro-arm-linux-gnueabihf/bin' >> ~/.bashrc
RUN rm *.tar.bz2

# Build Linux kernel for TZ3000
RUN git clone https://github.com/advaly/linux-3.4.25-ltsi-ApPLite --depth 1
WORKDIR /root/linux-3.4.25-ltsi-ApPLite
RUN make ARCH=arm wbcam_defconfig
RUN make ARCH=arm CROSS_COMPILE=/opt/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf- LOADADDR=0x80200000 modules uImage -j $(nproc)
RUN make modules_install INSTALL_MOD_PATH=./modules
RUN make headers_install INSTALL_HDR_PATH=./usr

# Build U-Boot for TZ3000
WORKDIR /root
RUN git clone https://github.com/advaly/u-boot-tz3000 --depth 1
WORKDIR /root/u-boot-tz3000
RUN make CROSS_COMPILE=/opt/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf- SRC_DEBUG=1 tz3000eva_ref4_config
RUN make CROSS_COMPILE=/opt/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
