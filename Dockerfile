FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y gcc g++ gfortran libgcrypt20-dev libncurses5-dev make python libcurl3 php5-curl && \
    apt-get autoremove && apt-get autoclean
    
RUN curl -L -C - -o archives/munge-0.5.12.tar.xz "https://github.com/dun/munge/releases/download/munge-0.5.12/munge-0.5.12.tar.xz" && \
    curl -L -C - -o archives/slurm-17-02-6-1.tar.gz "https://github.com/SchedMD/slurm/archive/slurm-17-02-6-1.tar.gz" && \
    curl -L -C - -o archives/openmpi-2.1.1.tar.bz2 "https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.bz2"
    
COPY archives/munge-0.5.12.tar.xz /root
COPY archives/slurm-17-02-6-1.tar.gz /root
COPY archives/openmpi-2.1.1.tar.bz2 /root

RUN mkdir -p /root/local/src && \
    cd /root/local/src && tar axvf /root/munge-0.5.12.tar.xz && cd /root/local/src/munge-0.5.12 && \
    ./configure --prefix=/usr/local && \
    make -j && make install && \
    cd /root && rm -rf /root/local/src/munge-0.5.12
RUN cd /root/local/src && tar axvf /root/slurm-17-02-6-1.tar.gz && cd /root/local/src/slurm-slurm-17-02-6-1 && \
    ./configure --prefix=/usr/local && \
    make -j && make install && \
    cd /root && rm -rf /root/local/src/slurm-slurm-17-02-6-1
RUN cd /root/local/src && tar axvf /root/openmpi-2.1.1.tar.bz2 && cd /root/local/src/openmpi-2.1.1 && \
    ./configure --prefix=/usr/local --with-pmi=/usr/local && \
    make -j && make install && \
    cd /root && rm -rf /root/local/src/openmpi-2.1.1

RUN echo 'btl_tcp_if_exclude = lo,docker0' >> /usr/local/etc/openmpi-mca-params.conf
RUN cp /usr/local/lib/libmpi_usempif08.so.20 /usr/lib/libmpi_usempi.so.20 && ldconfig
RUN useradd munge -m && useradd slurm -m && mkdir /tmp/slurm && chown slurm:slurm -R /tmp/slurm

COPY scripts/munged.sh /scripts/munged.sh
COPY scripts/slurm-config.sh /scripts/slurm-config.sh
COPY scripts/leader.sh /scripts/leader.sh
COPY scripts/follower.sh /scripts/follower.sh
COPY config/slurm.conf.template /usr/local/etc/
