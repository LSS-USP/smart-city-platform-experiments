FROM ruby:2.3.1-onbuild
RUN mkdir -p /benchmark/
ADD . /benchmark/
WORKDIR /benchmark/
RUN bundle install
CMD [ "ruby src/main.rb"]

