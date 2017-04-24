FROM centos:7
MAINTAINER ReDeployIO <redeployio@gmail.com>

# Install Essentials
RUN yum update -y && \
    yum install -y git && \
    yum install -y wget && \
    yum install -y openssh-server && \
    yum install -y java-1.8.0-openjdk && \
    yum install -y sudo && \
    yum clean all

# gen dummy keys, centos doesn't autogen them like ubuntu does
RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User
RUN useradd jenkins -m -s /bin/bash && \
    mkdir /home/jenkins/.ssh

COPY /files/authorized_keys /home/jenkins/.ssh/authorized_keys
COPY /files/.gitconfig /home/jenkins/.gitconfig

RUN chown -R jenkins /home/jenkins && \
    chgrp -R jenkins /home/jenkins && \
    chmod 600 /home/jenkins/.ssh/authorized_keys && \
    chmod 700 /home/jenkins/.ssh && \
    touch /home/jenkins/.ssh/known_hosts && \ 
    ssh-keyscan -t rsa github.com >> /home/jenkins/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> /home/jenkins/.ssh/known_hosts && \
    echo "jenkins    ALL=(ALL)    ALL" >> etc/sudoers

# Set Name Servers
COPY /files/resolv.conf /etc/resolv.conf

# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]

