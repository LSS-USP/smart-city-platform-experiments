# Poupalte the InterSCity platform with parking spots resources

This repository contains the script to register all parking spots from both Zona Azul
and OpenStreetMaps into the InterSCity platform 

## Setup

* Build the image:
```sh
docker build --tag <repository>:<tag>
```
Example:
```sh
docker build --tag arthurmde/parking-spots-creation:0.1-0.1-exp2
```
* Run a new container based on this image
```sh
docker run -d arthurmde/parking-spots-creation:0.1-0.1-exp2 -e "INTERSCITY_HOST=localhost:8000"
```
