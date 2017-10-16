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

You must also increase the quota assigned for your project to create load balacers.
By default, GKE will allocate a number of "In-use IP addresses" equal to the
number of VMs in your cluster. However, you will need to expose the InterSCity
through Kong service for testing and experiments.

* Perform the following steps to install gcloud SDK:
```sh
# Create an environment variable for the correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

# Add the Cloud SDK distribution URI as a package source
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk
```
* Initialize the SDK and chose a project:
```sh
gcloud init
```

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

# TODO

* [ ] For each stolon-sentinel, get cluster data
* [ ] Separate node-pools on google to run databases. In a containner spec you may use:
```yaml
nodeSelector:
  cloud.google.com/gke-nodepool: db-pool
```
* [ ] Run the simulator on cluster
* [ ] Wait for all machines be in 'running' status to start experiment


# References

* RabbitMQ
  * https://wesmorgan.svbtle.com/rabbitmq-cluster-on-kubernetes-with-statefulsets
* MongoDB
  * http://blog.kubernetes.io/2017/01/running-mongodb-on-kubernetes-with-statefulsets.html
  * https://www.mongodb.com/blog/post/running-mongodb-as-a-microservice-with-docker-and-kubernetes
* Postgres
  * https://github.com/sorintlab/stolon/blob/master/examples/kubernetes/README.md
* etcd
  * https://github.com/coreos/etcd/tree/master/hack/kubernetes-deploy
* Rails APP
  * https://engineering.adwerx.com/rails-on-docker-compose-7e2cf235fa0e
  * https://engineering.adwerx.com/rails-on-kubernetes-8cd4940eacbe
* Autoscaling
  * http://blog.kubernetes.io/2016/07/autoscaling-in-kubernetes.html
