# Parse for Private Parking from Google Places API

This repository contains the script to parse Google Places API to create city
resources in InterSCity platform from private parking data of São Paulo city. 

The *parser.rb* will access [Google Places API](https://developers.google.com/places/)
to get all available parkings and generates an easy-to-read XML file in the
folder [output](output) with the location of each parking spots.

## Setup

* To request an API key, point your browser to [code.google.com/apis/console](https://code.google.com/apis/console)
and follow the instructions there.
* Insert you API key in the [config.yml file](config.yml)
* Install Ruby 2.4.0
* Install bundler:
```sh
gem install bundler
```
* Install depencies with bundler:
```sh
bundle install
```
## Running

```sh
ruby parser.rb
```
