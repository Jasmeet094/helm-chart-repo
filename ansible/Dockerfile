FROM python:3.8
WORKDIR /data/ansible
ENV SAML2AWS_VERSION=2.36.13
ENV SAML2AWS_DOWNLOAD_URL=https://github.com/Versent/saml2aws/releases/download/v${SAML2AWS_VERSION}/saml2aws_${SAML2AWS_VERSION}_linux_amd64.tar.gz
RUN curl -L "$SAML2AWS_DOWNLOAD_URL" -o saml2aws.tar.gz && \
    tar xvfz saml2aws.tar.gz && \
    mv saml2aws /usr/local/bin/saml2aws && \
    chmod +x /usr/local/bin/saml2aws && \
    rm saml2aws.tar.gz
COPY requirements.yml requirements.yml
RUN pip install --no-cache-dir ansible==5.6.0 awscli==1.31.11 boto3==1.33.11
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends vim telnet less jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN ansible-galaxy install -r requirements.yml