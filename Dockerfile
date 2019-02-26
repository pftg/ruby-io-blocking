FROM ruby:2.6.1-alpine3.9

RUN apk add --update alpine-sdk
RUN gem install concurrent-ruby concurrent-ruby-ext lightio async async-http

RUN mkdir /app
COPY . /app