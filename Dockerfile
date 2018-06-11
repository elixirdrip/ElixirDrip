FROM elixir:1.6.4-alpine

ENV TERM xterm
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV REFRESHED_AT 2018-06-06

ENV APP_PATH /opt/app
ENV APP_NAME elixir_drip
ENV APP_VERSION 0.0.8
ENV HTTP_PORT 4000
ENV HTTPS_PORT 4040
ENV MIX_ENV prod
ENV REPLACE_OS_VARS true

RUN apk add --no-cache build-base git nodejs nodejs-npm
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force
RUN mix local.hex --force && mix local.rebar --force

COPY . $APP_PATH/$APP_NAME

WORKDIR $APP_PATH/$APP_NAME

RUN rm -rf _build  \
    && rm -rf deps \
    && rm -rf logs

RUN MIX_ENV=$MIX_ENV mix clean \
    && MIX_ENV=$MIX_ENV mix deps.get \
    && MIX_ENV=$MIX_ENV mix compile
RUN cd apps/elixir_drip_web/assets \
    && npm install \
    && ./node_modules/brunch/bin/brunch b -p

RUN cd $APP_PATH/$APP_NAME \
    && MIX_ENV=$MIX_ENV mix phx.digest \
    && MIX_ENV=$MIX_ENV mix release --env=$MIX_ENV

RUN mkdir -p /tmp/$APP_NAME
RUN cp $APP_PATH/$APP_NAME/_build/$MIX_ENV/rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.tar.gz /tmp/$APP_NAME

WORKDIR /tmp/$APP_NAME

RUN tar -xzf $APP_NAME.tar.gz
RUN rm -rf $APP_NAME.tar.gz

RUN echo "Release in place, ready to be copied."

EXPOSE $HTTP_PORT $HTTPS_PORT

CMD ["sh", "-c", "bin/$APP_NAME foreground"]
