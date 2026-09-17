FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# System, GUI, and EDA apt packages (including KLayout)
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo git bash vim tcsh gawk m4 pkg-config automake libtool ca-certificates curl wget \
    build-essential clang bison flex gperf zlib1g-dev \
    python3 python3-dev graphviz xdot \
    xfce4 xfce4-terminal faenza-icon-theme gnome-terminal xterm gedit \
    tigervnc-standalone-server \
    klayout \
    tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev \
    libreadline-dev libffi-dev libboost-system-dev libboost-python-dev libboost-filesystem-dev \
    libx11-6 libx11-dev libxrender1 libxrender-dev libxcb1 libx11-xcb-dev \
    libcairo2 libcairo2-dev libxpm4 libxpm-dev libxaw7-dev freeglut3-dev \
    yosys \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tools

# Build EDA tools
RUN git clone https://github.com/StefanSchippers/xschem.git xschem-src && \
    cd xschem-src && ./configure && make -j$(nproc) && make install && \
    cd /tools && rm -rf xschem-src

RUN git clone https://github.com/RTimothyEdwards/magic && \
    cd magic && ./configure && make -j$(nproc) && make install && \
    cd /tools && rm -rf magic

RUN git clone https://git.code.sf.net/p/ngspice/ngspice ngspice_git && \
    cd ngspice_git && ./autogen.sh && mkdir release && cd release && \
    ../configure --with-x --enable-xspice --disable-debug --enable-cider \
                 --with-readline=yes --enable-openmp --enable-osdi && \
    make -j$(nproc) && make install && \
    cd /tools && rm -rf ngspice_git

RUN git clone https://github.com/RTimothyEdwards/netgen.git && \
    cd netgen && ./configure && make -j$(nproc) && make install && \
    cd /tools && rm -rf netgen

RUN git clone https://github.com/RTimothyEdwards/open_pdks.git && \
    cd open_pdks && ./configure --enable-sky130-pdk && make -j$(nproc) && make install && \
    cd /tools && rm -rf open_pdks

# noVNC & websockify
RUN git clone https://github.com/novnc/noVNC /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# User setup
RUN useradd -m -s /bin/bash beta_vlsi && \
    echo "beta_vlsi:beta_vlsi" | chpasswd && \
    echo 'beta_vlsi ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER beta_vlsi
WORKDIR /home/beta_vlsi

RUN mkdir -p /home/beta_vlsi/.xschem/simulations && \
    printf "set ngbehavior=hsa\nset ng_nomodcheck\n" > /home/beta_vlsi/.xschem/simulations/.spiceinit && \
    mkdir -p /home/beta_vlsi/.vnc && \
    printf "#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n" > /home/beta_vlsi/.vnc/xstartup && \
    chmod +x /home/beta_vlsi/.vnc/xstartup

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    dbus-x11 papirus-icon-theme librsvg2-common && \
    update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper 2>/dev/null || true && \
    rm -rf /var/lib/apt/lists/*
RUN printf "This environment is designed for the EE 537 course under the supervision of Prof. Dr. Günhan Dündar by the course assistants.\n" > /README
# Wallpaper & Entrypoint
COPY wallpaper.jpeg /usr/share/backgrounds/wallpaper.jpeg
COPY --chmod=755 entry.sh /entry.sh

# Environment variables
ENV PDK_ROOT=/usr/local/share/pdk
ENV PDK=sky130A

# Build Gaw waveform viewer
RUN apt-get update && apt-get install -y --no-install-recommends libgtk-3-dev && \
    git clone https://github.com/StefanSchippers/xschem-gaw.git gaw && \
    cd gaw && ./configure && make -j$(nproc) && make install && \
    cd /tools && rm -rf gaw && \
    rm -rf /var/lib/apt/lists/*

USER beta_vlsi
WORKDIR /home/beta_vlsi

# Write permanent xschemrc configuration
RUN mkdir -p /home/beta_vlsi/.xschem && \
    printf 'set PDK_ROOT /usr/local/share/pdk\n\
set PDK sky130A\n\
set 130_PATH $PDK_ROOT/$PDK/libs.tech/xschem\n\
set XSCHEM_LIBRARY_PATH {}\n\
append XSCHEM_LIBRARY_PATH :${XSCHEM_SHAREDIR}/xschem_library/devices\n\
append XSCHEM_LIBRARY_PATH :${XSCHEM_SHAREDIR}/xschem_library\n\
append XSCHEM_LIBRARY_PATH :$130_PATH\n\
append XSCHEM_LIBRARY_PATH :$130_PATH/sky130_fd_pr\n\
append XSCHEM_LIBRARY_PATH :$130_PATH/sky130_tests\n\
append XSCHEM_LIBRARY_PATH :$130_PATH/sky130_stdcells\n\
append XSCHEM_LIBRARY_PATH :$130_PATH/mips_cpu\n\
append XSCHEM_LIBRARY_PATH :[file dirname [file normalize [info script]]]\n\
set SKYWATER_MODELS $PDK_ROOT/$PDK/libs.tech/combined\n\
set SKYWATER_STDCELLS $PDK_ROOT/$PDK/libs.ref/sky130_fd_sc_hd/spice\n' > /home/beta_vlsi/.xschem/xschemrc
RUN echo 'set xschem_execute_scripts 1' >> /home/beta_vlsi/.xschem/xschemrc

# Upgrade KLayout to 0.30.12 at the end to keep Docker build cache
USER root
RUN curl -L -O https://www.klayout.org/downloads/Ubuntu-22/klayout_0.30.12-1_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./klayout_0.30.12-1_amd64.deb && \
    rm -f klayout_0.30.12-1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*
USER beta_vlsi
WORKDIR /home/beta_vlsi
# Auto-link Sky130 PDK tech and layer properties into KLayout
RUN mkdir -p /home/beta_vlsi/.klayout/tech && \
    ln -snf /usr/local/share/pdk/sky130A/libs.tech/klayout /home/beta_vlsi/.klayout/tech/sky130A
ENTRYPOINT ["/entry.sh"]
