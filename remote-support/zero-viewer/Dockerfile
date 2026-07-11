# Ubuntu LTS release
FROM ubuntu:noble

# Prevent interactive installation dialogs, prompts, or warnings
ENV DEBIAN_FRONTEND=noninteractive

# Package updates, installations, and cache purges
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server \
        libpam-pwdfile \
        ca-certificates \
        libpam-modules \
        passwd \
    && rm -rf /var/lib/apt/lists/*


COPY ./setup/entrypoint.sh  /usr/local/bin/
COPY ./setup/constants.conf /usr/local/bin/constants.conf
COPY ./setup/sshd/sshd.pam  /etc/pam.d/sshd
COPY ./setup/sshd/security.conf    /etc/ssh/sshd_config.d/security.conf
COPY ./setup/sshd/whitelist.conf   /etc/ssh/sshd_config.d/whitelist.conf
COPY ./setup/sshd/zeroviewer.conf  /etc/ssh/sshd_config.d/zeroviewer.conf

RUN chmod 755 /usr/local/bin/entrypoint.sh && \
    chown root:root /usr/local/bin/entrypoint.sh && \
    chmod 644 /usr/local/bin/constants.conf && \
    chmod 644 /etc/pam.d/sshd && \
    chmod 644 /etc/ssh/sshd_config.d/security.conf && \
    chmod 644 /etc/ssh/sshd_config.d/whitelist.conf && \
    chmod 644 /etc/ssh/sshd_config.d/zeroviewer.conf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
