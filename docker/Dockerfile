# We use a base from nvidia where we know cuda 9.0 will work
FROM nvidia/cuda:9.0-runtime-ubuntu16.04

# Install conda
# Adapted from https://github.com/ContinuumIO/docker-images/blob/737e57d3997a079897cc6fc95ff9097ffee19fad/miniconda3/debian/Dockerfile

# First we need to update ubuntu and install wget.
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        ca-certificates \
        git \
        openssh-client \
        wget \
        curl \
# Cleanup apt-get
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Select what version of miniconda to get
ARG CONDA_VERSION=py39_4.10.3
ARG CONDA_ARCH=Linux-x86_64

# Then we download and install conda in /opt/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-${CONDA_ARCH}.sh -O miniconda.sh && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# Install DeepMicrobes packages -- these steps take a long time
COPY install.yml .

RUN /opt/conda/bin/conda env create -f install.yml && \
# Make DeepMicrobes the default environment
    echo "conda activate DeepMicrobes" >> ~/.bashrc && \
# Activate DeepMicrobes
    . /opt/conda/etc/profile.d/conda.sh && \
    conda activate DeepMicrobes && \
# Install the right version of tensorflow-base to make tensorflow-gpu work
# Installing it with "tensorflow-base=1.9.0=gpu_py36h6ecc378_0" within install.yml didn't work...
    conda install -y tensorflow-base=1.9.0=gpu_py36h6ecc378_0 && \
# Cleanup conda again
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# Install parallel and any other packages we need
# Added a second apt-get install so that the rebuild doesn't take so darn long when needed.
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
# Add packages you need here
        parallel \
# Cleanup apt-get
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
	
# Let's try something different...
#RUN . /opt/conda/etc/profile.d/conda.sh && \
#    conda activate DeepMicrobes && \
#	pip uninstall -y numpy && \
#	yes | pip install --ignore-installed --upgrade --no-cache-dir \ 
#	https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.9.0-cp36-cp36m-linux_x86_64.whl

# So we do it again
#RUN /opt/conda/bin/pip install --no-cache-dir tensorflow-gpu==1.9.0

#RUN /opt/conda/bin/conda install tensorflow-gpu==1.9.0

#SHELL ["/bin/bash", "--login", "-c"]

# For some reason we don't get the proper tensorflow-gpu package

#RUN . /opt/conda/etc/profile.d/conda.sh && \
#    conda activate DeepMicrobes && \
#    conda install -y tensorflow-base=1.9.0=gpu_py36h6ecc378_0 && \
#    conda clean -afy

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

ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# We need to do some magic to make conda play nice
ADD docker/entrypoint.sh /root/entrypoint.sh
RUN chmod u+x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

CMD ["/bin/bash"]
