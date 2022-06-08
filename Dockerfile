FROM golang:latest

# Downlaod the latest version of the gcloud SDK
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Install gcloud SDK
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Install cfssl and cfssljson
RUN go install github.com/cloudflare/cfssl/cmd/...@latest

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install tmux
RUN apt update && apt install -y tmux

# Add gcloud to PATH
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

