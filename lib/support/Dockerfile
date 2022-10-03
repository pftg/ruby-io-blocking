FROM ruby:-alpine3.9

RUN apk add --update alpine-sdk
RUN gem install concurrent-ruby concurrent-ruby-ext lightio async async-http async-http-faraday

RUN mkdir /app
COPY ../.. /app
