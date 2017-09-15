# Parse for Zona Azul Shapefile

This repository contains the script to parse shapefiles of Zona Azul parking
spots from São Paulo city, 
[distributed by CET](http://www.cetsp.com.br/consultas/zona-azul/mapa-zona-azul/mapa-zona-azul.aspx).

The *parser.rb* script read three different [shapefiles](shapefiles) and
generates a easier to read XML file in the folder [output](output) with the location of each parking spots
of Zona Azul.

## Setup

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
