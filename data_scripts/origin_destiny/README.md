#Parse for São Paulo Subway Origin-Destiny Survey

This repository contains the script to parse the São Paulo Origin-Destiny Survey
to define the workload for experiments. More specifically, we are interested on
drivers arriving at their destination, since they will start to looking for
available parking spaces.

The *parser.rb* will read the CSV files and generate an easier-to-read CSV
file on folder [output](output).

## Setup

* Install Ruby 2.4.0
* Install required dependencies:
```sh
sudo apt-get install libmagickwand-dev imagemagick
```
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
