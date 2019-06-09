FROM gliderlabs/registrator:v7
COPY ecs_registrator.sh /usr/local/bin/ecs_registrator.sh
RUN apk-install bash
ENTRYPOINT ["ecs_registrator.sh"]
