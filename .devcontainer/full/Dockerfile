FROM mcr.microsoft.com/devcontainers/base:noble

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG GOPATH=/go
ARG GOMODCACHE=$GOPATH/pkg/mod
ARG WORKSPACES_DIR=/workspaces

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Configure CA certificates
COPY .devcontainer/full/ca-bundle.crt /usr/local/share/ca-certificates/ca-bundle.crt

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
    mysql-shell \
    python3 \
    python3-pip \
    shellcheck \
    shfmt \
    sqlite3 \
    sudo \
    tree \
    uuid-runtime \
    vim && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates && \
    go install github.com/asdf-vm/asdf/cmd/asdf@latest && \
    echo ". <(asdf completion bash)" >>/etc/bash.bashrc && \
    go install github.com/spf13/cobra-cli@latest && \
    go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest && \
    go install -tags 'sqlite3' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Create the user
RUN if existing_username=$(id -un "$USER_UID"); then userdel -r "$existing_username"; fi && \
    if ! getent group "$USER_GID" >/dev/null 2>&1; then groupadd --gid "$USER_GID" "$USERNAME"; fi && \
    useradd --uid "$USER_UID" --gid "$USER_GID" -s /bin/bash -m "$USERNAME" && \
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" >>"/etc/sudoers.d/$USERNAME" && \
    chmod 0440 "/etc/sudoers.d/$USERNAME" && \
    # Grant permissions to the user
    umask 0002 && \
    mkdir -p "$GOPATH" "$ASDF_DATA_DIR" "$WORKSPACES_DIR" && \
    groupadd -r golang && \
    groupadd -r asdf && \
    usermod -aG golang,asdf "$USERNAME" && \
    chown -R "$USER_UID:golang" "$GOPATH" && \
    chown -R "$USER_UID:asdf" "$ASDF_DATA_DIR" && \
    chown -R "$USER_UID:$USER_GID" "$WORKSPACES_DIR" && \
    find "$GOPATH" "$ASDF_DATA_DIR" "$WORKSPACES_DIR" -type d -exec chmod g+s {} +

# Configure git
RUN git config --system http.sslCAInfo "$CERT_PATH" && \
    git config --system init.defaultBranch main && \
    git config --system alias.cof "!git branch -a | fzf | xargs git checkout"

# Install java toolchain via sdkman
ENV SDKMAN_DIR=/usr/local/sdkman
ENV JAVA_HOME=$SDKMAN_DIR/candidates/java/current

RUN curl -sSL "https://get.sdkman.io?rcupdate=false" | bash && \
    echo -e "export SDKMAN_DIR=$SDKMAN_DIR\n. \$SDKMAN_DIR/bin/sdkman-init.sh" >>/etc/bash.bashrc && \
    source "$SDKMAN_DIR/bin/sdkman-init.sh" && \
    sdk install java 21.0.9-tem && \
    sdk install maven && \
    sdk install springboot && \
    keytool -importcert -trustcacerts -alias customca -file /usr/local/share/ca-certificates/ca-bundle.crt -cacerts -storepass changeit -noprompt && \
    # Grant permissions to the user
    groupadd -r sdkman && \
    usermod -aG sdkman "$USERNAME" && \
    chown -R "$USER_UID:sdkman" "$SDKMAN_DIR" && \
    find "$SDKMAN_DIR" -type d -exec chmod g+s {} +

# Install other tools via asdf
USER $USERNAME
WORKDIR $WORKSPACES_DIR
