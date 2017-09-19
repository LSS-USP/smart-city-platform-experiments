# Parse for Private Parking from Google Places API

This repository contains the script to parse the output of OpenStreetMaps API
from the seaerch of parking spaces in São Paulo city. The output of this script
will be used to define city resources in InterSCity platform. 

The *parser.rb* will access [the Open Street Maps XAPI](http://wiki.openstreetmap.org/wiki/Xapi)
to get all available parkings and generates an easy-to-read XML file in the
folder [output](output) with the location of each parking spots.

## Setup

* Run the following request with curl to get all data related to parking spaces on São Paulo city:
```sh
curl --location --globoff "http://overpass.osm.rambler.ru/cgi/xapi_meta?*[amenity=parking][bbox=-46.867260,-23.780220,-46.364635,-23.382500]" -o data.osm
```
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
