FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
        vim ca-certificates curl wget unzip gcc git make libc6-dev libfuse2 software-properties-common \
        x11-xkb-utils xauth xfonts-base xkb-data at-spi2-core libpci-dev openjdk-17-jdk \
        libegl1-mesa libgl1-mesa-dev libgl1-mesa-glx libglx-dev \
        libxcb-util1 libqt5x11extras5 libqt5dbus5 libqt5widgets5 libqt5network5 libqt5gui5 libqt5core5a \
        dbus-x11 xfce4 xfce4-panel xfce4-session xfce4-settings xorg xubuntu-icon-theme && \
    add-apt-repository ppa:mozillateam/ppa && \
    apt-get update && \
    apt-get -y install firefox-esr && \
    rm -rf /var/lib/apt/lists/*

# see http://bugs.python.org/issue19846
ENV LANG C.UTF-8

WORKDIR /tmp

# install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    rm -f packages.microsoft.gpg && \
    apt-get update && apt-get install -y code

# install miniconda3
RUN wget -O miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash miniconda3.sh -b -p /opt/conda && \
    rm /tmp/miniconda3.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda install mamba -n base -c conda-forge -y && \
    mamba update -n base -c defaults conda && \
    mamba install --channel conda-forge python=3.8 numpy -y && \
    echo "source activate" >> ~/.bashrc

# install turbiovnc and virtualgl
ARG TURBOVNC_VERSION=3.0.2
ARG LIBJPEG_VERSION=2.1.4
ARG VIRTUALGL_VERSION=3.0.2
RUN wget -q -O turbovnc.deb https://downloads.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
    wget -q -O libjpeg.deb https://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb && \
    wget -q -O virtualgl.deb https://downloads.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/TurboVNC/bin

# install noVNC and websockify
ARG NOVNC_VERSION=1.4.0
ARG WEBSOCKIFY_VERSION=0.11.0
RUN wget -q -O novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz && \
    mkdir -p /opt/noVNC && \
    tar -xzf novnc.tar.gz -C /opt/noVNC --strip-components 1 && \
    rm novnc.tar.gz && \
    wget -q -O websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz && \
    mkdir -p /opt/websockify && \
    tar -xzf websockify.tar.gz -C /opt/websockify --strip-components 1 && \
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
    xmlschema \
    decorator \
    notebook

RUN pip install \
      "napari[all]" \
      seaborn \
      opencv-python \
      napari-aicsimageio \
      cellpose-napari

ARG ILASTIK_VERSION=1.4.0rc8
RUN wget -q -O ilastik.tar.bz2 https://files.ilastik.org/ilastik-${ILASTIK_VERSION}-Linux.tar.bz2 && \
    mkdir -p /opt/ilastik && \
    tar -jxf ilastik.tar.bz2 -C /opt/ilastik --strip-components 1  && \
    rm ilastik.tar.bz2

ARG QUPATH_VERSION=0.4.2
RUN git clone https://github.com/qupath/qupath /tmp/qupath && \
    cd /tmp/qupath && \
    ./gradlew clean jpackage && \
    mv build/dist/QuPath /opt/ && \
    rm -rf /tmp/qupath

RUN wget -q -O fiji.zip https://downloads.imagej.net/fiji/latest/fiji-linux64.zip
RUN unzip fiji -d /opt && rm -rf fiji.zip && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site BigStitcher https://sites.imagej.net/BigStitcher/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site BaSiC https://sites.imagej.net/BaSiC/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site 'Local Z Projector' https://sites.imagej.net/LocalZProjector/ && \
    /opt/Fiji.app/ImageJ-linux64 --headless --update add-update-site 'Radial Symmetry' https://sites.imagej.net/RadialSymmetry/ && \
    /opt/Fiji.app/ImageJ-linux64 --update update

ARG OMERO_VERSION=5.8.0
RUN wget -q -O OMERO.insight.zip https://github.com/ome/omero-insight/releases/download/v${OMERO_VERSION}/OMERO.insight-${OMERO_VERSION}.zip && \
    unzip OMERO.insight.zip -d /opt && \
    wget -q -P /opt/Fiji.app/plugins/ https://github.com/ome/omero-insight/releases/download/v${OMERO_VERSION}/omero_ij-${OMERO_VERSION}-all.jar && \
    mv /opt/OMERO.insight-${OMERO_VERSION} /opt/OMERO.insight && \
    chmod +x /opt/OMERO.insight/bin/* && \
    rm OMERO.insight.zip

# cleanup
RUN rm -rf /tmp/* && \
    conda clean -yaq

RUN echo 'no-remote-connections\n\
no-pam-sessions\n\
no-httpd\n\
' > /etc/turbovncserver-security.conf

ENV DISPLAY :1
ENV XDG_RUNTIME_DIR /tmp/xdg/

COPY desktop.menu/* /usr/share/applications/
COPY xstartup /opt/xstartup

WORKDIR /

COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh

