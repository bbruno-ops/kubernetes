FROM centos:6

# set default environmental variables
ENV TAKIPI_COLLECTOR_HOST=collector
ENV TAKIPI_COLLECTOR_PORT=6060
ENV JAVA_TOOL_OPTIONS=-agentpath:/takipi/lib/libTakipiAgent.so
# to include application and deployment name:
# ENV JAVA_TOOL_OPTIONS=-agentpath:/takipi/lib/libTakipiAgent.so=takipi.application.name=<app name here>,takipi.deployment.name=<app version here>

# set working directory
WORKDIR /opt

# download and install the agent - extracts into the `takipi` folder.
# NOTE for Alpine, use: overops/agent-sidecar:alpine-latest
RUN curl -sL https://s3.amazonaws.com/app-takipi-com/deploy/linux/takipi-agent-latest.tar.gz | tar -xvzf -

# print version
RUN cat takipi/VERSION

# share /takipi between containers in a pod
VOLUME ["/takipi/"]

# create a run script to copy /opt/takipi/ (latest agent) to /takipi/ (shared)
RUN echo "#!/bin/bash" > run.sh \
 && echo "cat /opt/takipi/VERSION" >> run.sh \
 && echo "cp -a /opt/takipi/. /takipi/" >> run.sh \
 && echo "chmod -R 777 /takipi" >> run.sh \
 && echo "while [ ! -f /takipi/log/agents/*.log ] && [ ! -f /takipi/log/agents/bugtail_agent.startup ]; do" >> run.sh \
 && echo "sleep 2" >> run.sh \
 && echo "echo 'waiting for jvm startup'" >> run.sh \
 && echo "done" >> run.sh \
 && echo "tail -f /takipi/log/agents/*.log -f /takipi/log/agents/bugtale_agent.startup" >> run.sh \
 && chmod +x run.sh

CMD ["./run.sh"]
