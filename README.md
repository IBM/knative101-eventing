# Knative Eventing 101

Learn how to enable a service to consume events on Knative Eventing

## Introduction

Knative Eventing is a system that is designed to address a common need for cloud native development and provides composable primitives to enable late-binding event producers and event consumers.

In Knative, event producers and event consumers are designed to be independent. Any producer can generate events before there are active event consumers that are listening. Any event consumer can express interest in an event or class of events, before there are producers that are creating those events.

This tutorial can help you understand Knative Eventing concepts and how to use these concepts to enable Knative service to consume events.

## Prerequisites

Before you begin, you’ll need the following:

- [An IBM Cloud account](https://cloud.ibm.com/registration)
- A [IBM Kubernetes Service cluster](https://cloud.ibm.com/kubernetes/overview) is provisioned, at least with 2 worker nodes.
- [Setting up Knative in your cluster](https://cloud.ibm.com/docs/containers?topic=containers-serverless-apps-knative#knative-setup)
- [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/) is installed
- [Config Kubernetes CLI to manage IBM Kubernetes Service cluster on IBM Cloud](https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install#cs_cli_configure)
- [Git CLI client](https://git-scm.com/downloads) installed

## Estimated time

It should take you about 30 minutes to complete this tutorial.

## Steps

1. [Use `Importer` to define event producer-consumer](./step1)
3. [Use `Broker` and `Trigger` to manage events and subscriptions.](./step2)
4. [Add `Filter` to `Trigger`](./step3)

## Summary

In this tutorial, you learned two ways to consume events on Knative Eventing. With event `Importer`, you can directly link a event consumer to a producer and simply define an event message flow from a producer to a consumer. With `Broker` and `Trigger`, you can decouple event producers and consumers. `Broker` likes an event hub where all event producers send events to. `Trigger` describe event consumer and its intersted subscriptions to specific events, which enables late-binding event producers and event consumers.

## Related links

- [Kube101](https://github.com/IBM/kube101/tree/master/workshop)
- [Istio101](https://github.com/IBM/istio101/tree/master/workshop)
- [Knative101](https://github.com/IBM/knative101/tree/master/workshop)