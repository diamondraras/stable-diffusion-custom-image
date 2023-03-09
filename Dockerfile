
FROM nvcr.io/nvidia/pytorch:21.02-py3 AS runtime-base
LABEL maintainer="Diamondra Rasoamanana <diamondraras@gmail.com>"

RUN rm -rf /opt/pytorch  # remove 1.2GB dir


WORKDIR /app
RUN apt-get -y update
RUN apt-get -y install git

RUN git clone https://github.com/diamondraras/stable-diffusion.git


# Install base utilities
RUN apt-get install -y wget

# Install miniconda
ENV CONDA_DIR /opt/conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda env create -f stable-diffusion/environment.yaml


# Make RUN commands use the new environment:
SHELL ["/bin/bash", "-c"]
RUN source /opt/conda/etc/profile.d/conda.sh && conda activate ldm && pip install diffusers==0.12.1

RUN apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev

ARG MODEL_URL
RUN mkdir -p stable-diffusion/models/ldm/stable-diffusion-v1
RUN wget -O stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt --show-progress $MODEL_URL
RUN cd stable-diffusion && source /opt/conda/etc/profile.d/conda.sh && conda activate ldm && python3 -c "import scripts.txt2img"
# Build the text to image model
WORKDIR /app/stable-diffusion
ARG TEXT_PROMPT

COPY entrypoint.bash /app/stable-diffusion/entrypoint.bash
RUN chmod +x /app/stable-diffusion/entrypoint.bash

CMD ["./entrypoint.bash"]
