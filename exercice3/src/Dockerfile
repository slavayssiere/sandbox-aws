FROM golang:alpine AS build-env
RUN apk add --no-cache git
ADD . /src
RUN cd /src && go get -v -d && go build -o goapp

# final stage
FROM alpine
RUN apk add --no-cache curl
ENV PREFIX_PATH /
WORKDIR /app
COPY --from=build-env /src/goapp /app/
HEALTHCHECK --interval=5s --retries=3 --timeout=5s CMD curl -f http://localhost:8080$PREFIX_PATH/healthz || exit 1
ENTRYPOINT ./goapp
EXPOSE 8080