# Use the latest Ubuntu as the base image with x86 architecture
FROM --platform=linux/amd64 ubuntu:jammy

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
    apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get clean

# SSH login fix. Otherwise user is kicked off after login
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Install Python packages
RUN pip install parse robotframework

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions and zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy your local configurations
COPY .zshrc /root/.zshrc
COPY .p10k.zsh /root/.p10k.zsh

# Set Zsh as default shell (this is not necessary if you're only using the shell interactively)
RUN chsh -s $(which zsh)

# Set the working directory (optional, set it as per your project requirement)
WORKDIR /cs-202

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 userName 
RUN echo 'userName:cs-202/project' | chpasswd

# Start SSH Service (this should actually be handled by the container's CMD or ENTRYPOINT, not at build time)
# RUN service ssh start

# Expose the SSH port
EXPOSE 22

# Set the default command or entrypoint (starting SSH here as well to make sure it's running)
CMD ["/usr/sbin/sshd", "-D"]
