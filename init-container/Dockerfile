FROM debian:stretch-20200422-slim

RUN apt update -y

RUN apt install curl -y

COPY healthcheck.sh ./

RUN chmod 777 healthcheck.sh

USER 1000

CMD ["/bin/bash","healthcheck.sh"]
