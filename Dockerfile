FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim ca-certificates curl wget unzip gcc git make libc6-dev libfuse2 \
        x11-xkb-utils xauth xfonts-base xkb-data at-spi2-core libpci-dev \
        libegl-mesa0 libgl1-mesa-dev libgl1-mesa-glx libglx-dev \
        libxcb-util1 libqt5x11extras5 libqt5dbus5 libqt5widgets5 libqt5network5 libqt5gui5 libqt5core5a \
        dbus-x11 xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme firefox && \
    rm -rf /var/lib/apt/lists/*

# see http://bugs.python.org/issue19846
ENV LANG C.UTF-8

# install miniconda3 
RUN cd /tmp && \
    curl -fsSL -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda install mamba -n base -c conda-forge && \
    mamba update -n base -c defaults conda && \
    mamba install --channel conda-forge python=3.8 numpy && \
    echo "source activate" >> ~/.bashrc

# install turbiovnc and virtualgl
ARG TURBOVNC_VERSION=2.2.6
ARG VIRTUALGL_VERSION=2.6.5
ARG LIBJPEG_VERSION=2.1.0
RUN cd /tmp && \
    curl -fsSL \
       -O https://downloads.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
       -O https://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
       -O https://downloads.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/TurboVNC/bin

# install noVNC and websockify
ARG WEBSOCKIFY_VERSION=0.9.0
ARG NOVNC_VERSION=1.1.0
RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    cd /opt/websockify && make && \
    mkdir -p /opt/websockify/lib/ && \
    ln -s /opt/websockify/rebind.so /opt/websockify/lib/rebind.so


RUN mamba install -y -q -c conda-forge \
    zarr \
    fsspec \
    backcall \
    trackpy \
    dask-image \
    xmlschema==1.4.1 \
    decorator==4.4.2 \
    notebook

RUN pip install \
      "napari[all]==0.4.8" \
      seaborn \
      magicgui \
      opencv-python==4.1.2.30 \
      napari-aicsimageio \
      aicsimageio==3.3.4 \
      xarray==0.16.2 \
      cellpose-napari==0.1.3

ARG ILASTIK_VERSION=1.3.3
ARG QUPATH_VERSION=0.2.3
RUN curl -fsSL https://files.ilastik.org/ilastik-${ILASTIK_VERSION}-Linux.tar.bz2 | tar -jxf - -C /opt && \
    curl -fsSL https://github.com/qupath/qupath/releases/download/v${QUPATH_VERSION}/QuPath-${QUPATH_VERSION}-Linux.tar.xz | tar -Jxf - -C /opt && \
    mv /opt/ilastik-${ILASTIK_VERSION}-Linux /opt/ilastik && \
    mv /opt/QuPath-${QUPATH_VERSION} /opt/QuPath

RUN cd /tmp && \
    curl -fsSL https://downloads.imagej.net/fiji/latest/fiji-linux64.zip -o /tmp/fiji-linux64.zip && \
    unzip fiji-linux64.zip -d /tmp && mv /tmp/Fiji.app /opt/Fiji.app && rm -rf /tmp/fiji-linux64.zip && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site BigStitcher https://sites.imagej.net/BigStitcher/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site BaSiC https://sites.imagej.net/BaSiC/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site 'Local Z Projector' https://sites.imagej.net/LocalZProjector/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site 'Radial Symmetry' https://sites.imagej.net/RadialSymmetry/ && \
    /opt/Fiji.app/ImageJ-linux64 --update update

RUN conda clean --all --yes --quiet

RUN echo 'no-remote-connections\n\
no-pam-sessions\n\
no-httpd\n\
' > /etc/turbovncserver-security.conf


ENV DISPLAY :1
ENV XDG_RUNTIME_DIR /tmp/xdg/

COPY desktop.menu/* /usr/share/applications/
COPY xstartup /opt/xstartup

# build resources now because /opt/conada will be Read Only from Singularity
RUN python -c "import napari; napari._qt.qt_resources._icons._register_napari_resources()"

COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh

