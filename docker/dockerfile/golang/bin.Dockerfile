FROM alpine:latest
WORKDIR /app

RUN apk add libc6-compat --no-cache
RUN apk add curl --no-cache

COPY ./main /app/main
RUN chmod +x /app/main

CMD /app/main
