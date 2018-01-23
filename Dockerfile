FROM ruby:2.5

ADD . /srv/app
WORKDIR /srv/app
RUN bundle install --without test,development --path vendor/bundle
EXPOSE 8080
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8080"]
