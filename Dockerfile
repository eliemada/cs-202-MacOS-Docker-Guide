# Use the latest Ubuntu as the base image with x86 architecture
FROM ubuntu:jammy

# Set environment variables to reduce unnecessary prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install SSH and update packages
RUN apt-get update && apt-get install -y \
    openssh-client \
    openssh-server \
    gcc \
    g++ \
    gdb \
    clang \
    cmake \
    rsync \
    tar \
    astyle \
    build-essential \
    check \
    git \
    wdiff \
    colordiff \
    manpages \
    manpages-dev \
    doxygen \
    curl \
    graphviz \
    libssl-dev \
    libssl-doc \
    libjson-c-dev \
    pkg-config \
    libvips-dev \
    python3 \
    python3-pip \
    zsh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH login fix. Otherwise user is kicked off after login
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Install Python packages
RUN pip install parse robotframework

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme for Zsh
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions and zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy Zsh config for root
COPY .zshrc /root/.zshrc
COPY .p10k.zsh /root/.p10k.zsh

# Add userName with Zsh as default shell and set up Zsh configurations for this user
RUN groupadd userName && \
    useradd -m -d /home/userName -s /usr/bin/zsh -g userName -G sudo -u 1000 userName && \
    echo 'userName:cs-202/project' | chpasswd && \
    mkdir -p /home/userName && \
    cp -r /root/.oh-my-zsh /home/userName/.oh-my-zsh && \
    cp /root/.zshrc /home/userName/.zshrc && \
    cp /root/.p10k.zsh /home/userName/.p10k.zsh && \
    chown -R userName:userName /home/userName


# Expose the SSH port
EXPOSE 22

# Start the SSH service
CMD ["/usr/sbin/sshd", "-D"]
