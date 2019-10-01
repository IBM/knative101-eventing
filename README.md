# Knative Eventing 101

In these tutorial exercises, you learn how to enable a service to consume events on Knative [Eventing](https://knative.dev/docs/eventing/).

## Introduction

Knative Eventing is a system that is designed to address a common need for cloud native development by providing composable primitives to enable late-binding between event producers and event consumers.

In Knative, event producers and event consumers are designed to be independent. Any producer can generate events before there are active event consumers that are listening. Any event consumer can express interest in an event or class of events, before there are producers that are creating those events.

Completing these exercises can help you understand Knative Eventing concepts and how to use these concepts to enable Knative service to consume events.

You learn two ways to consume events on Knative Eventing:
- With event sources, you can directly link an event consumer to a producer and simply define an event message flow from a producer to a consumer. 
- With Broker and Trigger, you can decouple event producers and consumers. Broker is like an event hub where event producers send events to. Trigger describes an event consumer and its interested subscriptions to specific events that flow through the broker, which enables late-binding event producers and event consumers.

## Prerequisites

Before you begin, you’ll need the following:

- [An IBM Cloud account](https://cloud.ibm.com/registration).
- An [IBM Kubernetes Service cluster](https://cloud.ibm.com/kubernetes/overview) is provisioned, with at least 2 worker nodes.
- Knative set up, as described in [Setting up Knative in your cluster](https://cloud.ibm.com/docs/containers?topic=containers-serverless-apps-knative#knative-setup).
- [An installed Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- The Kubernetes CLI configured to manage the IBM Cloud Kubernetes Service, as described in [Configing Kubernetes CLI to run kubectl](https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install#cs_cli_configure).

## Estimated time

It should take you about 30 minutes to complete this tutorial.

## Steps

1. Exercise 1: [Subscribe to event producers by defining event sources](./step1)
2. Exercise 2: [Manage events and subscriptions with `Broker` and `Trigger`](./step2)
3. Exercise 3: [Add `Filter` to `Trigger`](./step3)

## Related links

- [Kube101](https://github.com/IBM/kube101/tree/master/workshop)
- [Istio101](https://github.com/IBM/istio101/tree/master/workshop)
- [Knative101](https://github.com/IBM/knative101/tree/master/workshop)