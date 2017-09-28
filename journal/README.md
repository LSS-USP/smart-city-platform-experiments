# Experiment

This experiment aims at evaluating the InterSCity Platform perfomance and
scalability in a real smart city enviornment. For this purpose,
this repository has the scripts to run the platform on [GKE](https://cloud.google.com/container-engine).

# Setup

You need gcloud and kubectl command-line tools installed and set upto run 
deployment commands. Also make sure your Google Cloud account has
STATIC\_ADDRESSES available for the external access of Kong services.
[Follow the installation and login steps of Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)

As long as we use GKE's elastic features, you will need to create a new project
and [enable billing](https://support.google.com/cloud/answer/6293499?hl=pt-br#enable-billing)
for it.

* Test if it is everything ok:
```sh
gcloud compute machine-types list
```
* Installing kubectl:
```sh
sudo apt-get install kubectl
```

* Set the default zone:
```sh
gcloud config set compute/zone us-central1-f
```
