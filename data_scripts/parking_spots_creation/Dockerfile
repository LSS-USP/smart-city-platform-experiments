FROM ruby:2.3-jessie
RUN apt update -qy && apt install bundler libxml2 zlib1g-dev -yq
RUN mkdir -p /parking_spots_creation/
ADD . /parking_spots_creation/
WORKDIR /parking_spots_creation/
RUN bundle install
CMD [ "bundle","exec", "ruby", "populate_platform.rb" ]
