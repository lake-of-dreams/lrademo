# Microservices, Saga Pattern and Long-Running actions with MicroTx

In the world of microservices architecture, managing complex transactions across multiple services can be a daunting task. Enter the saga pattern and long-running actions (LRAs), powerful tools that enable you to maintain data consistency while keeping your applications resilient and scalable. The [Oracle Transaction Manager for Microservices](https://www.oracle.com/in/database/transaction-manager-for-microservices/) provides tooling for implementing such transactional microservices in a easy way.

This example provides guidelines for installing [MicroTx sample](https://github.com/oracle-samples/microtx-samples/tree/main/lra/lrademo) in a Kubernetes cluster with Oracle Transaction Manager for Microservices (MicroTx) Free.

## Getting started

### Deploy The Microservices and OTMM

Modify [deploy.sh](./deploy.sh) to specify the prefix of docker repo to which you want to push and access the images from in `REPO` variable and execute

```shell
./deploy.sh
```

The script contains instructions to create a cluster, deploy the transaction manager and the Microservices in the cluster and create a pod to access the microservices.

### Initiate and confirm LRA

Execute

```shell
./run.sh
```

to initiate and confirm a Trip booking Saga. You can refer to https://github.com/oracle-samples/microtx-samples/blob/main/lra/lrademo/README.md for additional use cases for the Trip booking example.
