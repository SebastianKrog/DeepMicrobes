# We use a base from nvidia where we know cuda 9.0 will work
FROM nvidia/cuda:9.0-base

# Install conda
# Adapted from https://github.com/ContinuumIO/docker-images/blob/737e57d3997a079897cc6fc95ff9097ffee19fad/miniconda3/debian/Dockerfile

# First we need to update ubuntu
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
	parallel \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        mercurial \
        openssh-client \
        procps \
        subversion \
        wget \
		curl \
	&& apt-get remove -q -y python \
	&& apt-get autoremove -q -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# Select what version of miniconda to get
ARG MINICONDA_VERSION=Miniconda2-py27_4.8.3
ARG MINICONDA_ARCH=Linux-x86_64

# Then we download and install conda in /opt/conda
RUN wget https://repo.anaconda.com/miniconda/$MINICONDA_VERSION-$MINICONDA_ARCH.sh -O miniconda.sh && \
  mkdir -p /opt && \
  sh miniconda.sh -b -p /opt/conda && \
  rm miniconda.sh && \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
  echo "conda activate base" >> ~/.bashrc && \
  find /opt/conda/ -follow -type f -name '*.a' -delete && \
  find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
  /opt/conda/bin/conda clean -afy

WORKDIR /root/

# Install DeepMicrobes packages -- these steps take a long time
COPY docker/install_docker.yml .

RUN /opt/conda/bin/conda install --channel conda-forge --channel bioconda --file install_docker.yml && \
    /opt/conda/bin/conda clean -afy

# For some reason we don't get the proper tensorflow-gpu package (above only install tensorflow-gpu
# So we do it again
RUN /opt/conda/bin/pip install --no-cache-dir tensorflow-gpu==1.9.0

#SHELL ["/bin/bash", "--login", "-c"]

# Install DeepMicrobes scripts
RUN mkdir DeepMicrobes

WORKDIR /root/DeepMicrobes

COPY bin ./bin
COPY data ./data
COPY models ./models
COPY pipelines ./pipelines
COPY scripts ./scripts
COPY utils ./utils
COPY DeepMicrobes.py .

# Add the scripts to PATH
ENV PATH=/root/DeepMicrobes/:/root/DeepMicrobes/bin:/root/DeepMicrobes/scripts:/root/DeepMicrobes/pipelines:$PATH

# We need to do some magic to make conda play nice
ADD docker/entrypoint.sh /root/entrypoint.sh
RUN chmod u+x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

CMD ["/bin/bash"]
