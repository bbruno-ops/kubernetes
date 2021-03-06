FROM centos:8

# update
RUN dnf -y update

# install OpenJDK 8
RUN dnf install --noplugins -y java-1.8.0-openjdk-devel

# rootless
RUN groupadd --gid 1000 overops
RUN adduser --home /opt/takipi-storage --uid 1000 -g 1000 overops
USER 1000:1000

# install into the /opt directory
WORKDIR /opt

# download and install the latest storage server for S3
RUN curl -sL http://app-takipi-com.s3.amazonaws.com/deployx/s3/deploy/takipi-storage/takipi-storage-latest.tar.gz | tar -xvzf -

# use mount to make settings.yaml available
# see: https://doc.overops.com/docs/installing-the-storage-server-on-aws-s3
VOLUME ["/opt/takipi-storage/private"]

WORKDIR /opt/takipi-storage

# create a run script
RUN echo "#!/bin/bash" > run.sh \
  && echo "java -jar /opt/takipi-storage/lib/takipi-storage.jar server /opt/takipi-storage/private/settings.yaml &> /opt/takipi-storage/log/takipi-storage.log &" >> run.sh \
  && echo "/usr/bin/tail -f /opt/takipi-storage/log/takipi-storage.log" >> run.sh \
  && chmod +x run.sh

EXPOSE 8080 8081

# run the service, printing logs to stdout
CMD ["./run.sh"]
