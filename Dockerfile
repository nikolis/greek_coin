# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
ARG ALPINE_VERSION=3.9

FROM bitwalker/alpine-elixir:latest AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME=greek_coin
# The version of the application we are building (required)
ARG APP_VSN=0.1.1
# The environment to build with
ARG MIX_ENV=prod
# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=false
# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force



# This copies our app source code into the build container
COPY . .

RUN mix do deps.get, deps.compile, compile

# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
  cd ${PHOENIX_SUBDIR}/assets && \
  yarn install && \
  yarn deploy && \
  cd - && \
  mix phx.digest; \
fi

RUN \
  mkdir -p /opt/built && \
  mix distillery.release --verbose && \
  cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME=greek_coin

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev \
      openssl\
      erlang-crypto 

COPY  /SSL_PrivateKEY_www_greek-coin_com.txt /opt/app/lib/greek_coin-0.1.1/
COPY /www_greek-coin_com.crt /opt/app/lib/greek_coin-0.1.1/


ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME}

WORKDIR /opt/app

COPY --from=builder /opt/built .
RUN echo $DATABASE_HOST
RUN echo $DATABASE_USER
RUN echo $DATABASE_PASS
RUN echo $DATABASE_NAME
EXPOSE 80

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
