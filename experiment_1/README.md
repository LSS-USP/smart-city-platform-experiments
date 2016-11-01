# Experiment 1

* **Goal**
  * Test exmperimental setup
  * Identify bottlenecks in the scenario of data collection
* **Evaluation Technique:** Simulation
* **Research Questions:**
  * RQ1: What microservices requires more computational resources? 
  * RQ2: What microservices fail to provide its services?
* **Start:**
* **End:**
* **Duration:**

## Tools

* Benchmarking: Scalability Explorer Framework
* Deploy: ?

## Deploy parameters

* Cloud environment: 

* Resource Adaptor:
  * VM1
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
  * SO: 
* Resource Cataloguer
  * VM2
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* Data Collector
  * VM3
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* Resource Discoverer
  * VM4
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* RabbitMQ
  * VM5
  * DISK: 20 GB
  * CPU: 4
  * RAM: 512 MB
* PostgreSQL
  * VM6
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* City Workload Agent
  * VM6
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* Monitoring (Client) Service
  * VM7
  * DISK: 20 GB
  * CPU: 1
  * RAM: 512 MB
* Experiment Manager
  * Notebook
  * CPU: Core 2 Duo (2 cores)
  * RAM: 4 GB
  * SO: Debian 8

## Benchmarking

* Strategy: Change load between subsequent workload runs without changing
system capacity

### Input Stream Workload

Use a bi-modal input stream may represent two peaks during the morning and
evening periods

1. Choose a trace provided by sensor data from a city
2. Use a fixed-period of the trace for the experiment
3. 

### Client Workload

Constant low rate to each microservices
  * Actuator Controller:

## Results

