FROM ubuntu:noble

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG GOPATH=/go
ARG GOMODCACHE=$GOPATH/pkg/mod
ARG WORKSPACES_DIR=/workspaces

SHELL ["/bin/bash", "-c"]

# Configure CA certificates
# COPY .devcontainer/ca-bundle.crt /usr/local/share/ca-certificates/ca-bundle.crt

ENV CERT_PATH=/etc/ssl/certs/ca-certificates.crt
ENV CERT_DIR=/etc/ssl/certs
ENV SSL_CERT_FILE=$CERT_PATH
ENV SSL_CERT_DIR=$CERT_DIR
ENV CURL_CA_BUNDLE=$CERT_PATH
ENV REQUESTS_CA_BUNDLE=$CERT_PATH
ENV PIP_CERT=$CERT_PATH
ENV NODE_EXTRA_CA_CERTS=$CERT_PATH

# Base setup
ENV GOPATH=$GOPATH
ENV GOMODCACHE=$GOMODCACHE
ENV ASDF_DATA_DIR=/usr/local/asdf
ENV PATH=$ASDF_DATA_DIR/shims:$GOPATH/bin:$PATH

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    curl \
    default-mysql-client \
    fzf \
    git \
    golang \
    iproute2 \
    mysql-shell \
    npm \
    openssh-client \
    python3 \
    python3-pip \
    shellcheck \
    shfmt \
    sqlite3 \
    sudo \
    tree \
    unzip \
    uuid-runtime \
    vim \
    zip && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates && \
    go install github.com/asdf-vm/asdf/cmd/asdf@latest && \
    echo ". <(asdf completion bash)" >> /etc/bash.bashrc && \
    go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest && \
    go install -tags 'sqlite3' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Create the user
RUN if tmp=$(id -nu $USER_UID); then userdel -r $tmp; fi && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -s /bin/bash -m $USERNAME && \
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    # Grant permissions to the user
    umask 0002 && \
    mkdir -p $GOPATH $ASDF_DATA_DIR $WORKSPACES_DIR && \
    groupadd -r golang && \
    groupadd -r asdf && \
    usermod -aG golang,asdf $USERNAME && \
    chown -R $USERNAME:golang $GOPATH && \
    chown -R $USERNAME:asdf $ASDF_DATA_DIR && \
    chown -R $USERNAME:$USERNAME $WORKSPACES_DIR && \
    find $GOPATH $ASDF_DATA_DIR $WORKSPACES_DIR -type d -exec chmod g+s {} +

# Configure git
RUN git config --system http.sslCAInfo "$CERT_PATH" && \
    git config --system init.defaultBranch main && \
    git config --system alias.cof "!git branch -a | fzf | xargs git checkout"

# Install java toolchain via sdkman
ENV SDKMAN_DIR=/usr/local/sdkman
ENV JAVA_HOME=$SDKMAN_DIR/candidates/java/current

RUN curl -s "https://get.sdkman.io?rcupdate=false" | bash && \
    echo -e "export SDKMAN_DIR=$SDKMAN_DIR\n. $SDKMAN_DIR/bin/sdkman-init.sh" >> /etc/bash.bashrc && \
    source $SDKMAN_DIR/bin/sdkman-init.sh && \
    sdk install java 21.0.8-tem && \
    sdk install maven && \
    sdk install springboot && \
    # keytool -importcert -trustcacerts -alias customca -file /usr/local/share/ca-certificates/ca-bundle.crt -cacerts -storepass changeit -noprompt && \
    # Grant permissions to the user
    groupadd -r sdkman && \
    usermod -aG sdkman $USERNAME && \
    chown -R $USERNAME:sdkman $SDKMAN_DIR && \
    find $SDKMAN_DIR -type d -exec chmod g+s {} +

USER $USERNAME
WORKDIR $WORKSPACES_DIR
