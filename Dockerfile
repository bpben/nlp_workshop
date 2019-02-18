# Copyright (c) Ben Batorsky.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/base-notebook

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    emacs \
    git \
    # inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    pandoc \
    python-dev \
    # texlive-fonts-extra \
    # texlive-fonts-recommended \
    # texlive-generic-recommended \
    # texlive-latex-base \
    # texlive-latex-extra \
    # texlive-xetex \
    unzip \
    nano \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Setup pydata directory for backward-compatibility
RUN mkdir /home/$NB_USER/nlp_workshop && \
    fix-permissions /home/$NB_USER

COPY nlp_workshop_participant.ipynb nlp_workshop/
COPY ./data/website_text.csv nlp_workshop/data/

# Install Python 3 packages
RUN conda install --quiet --yes \
    'conda-forge::blas=*=openblas' \
    'ipywidgets=7.2*' \
    'pandas=0.23*' \
    'numexpr=2.6*' \
    'matplotlib=2.2*' \
    'scipy=1.1*' \
    'scikit-learn=0.19*' \
    'spacy=2.0*' && \
    pip install PyStemmer && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

USER $NB_UID