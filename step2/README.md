# Exercise 2: Use `Broker` and `Trigger` to manage events and subscriptions

If you want to decouple event providers and consumers, you can use `Broker` and `Trigger` to manage events and subscriptions. A broker is something in the middle of providers and consumers which receives events and forwards them to subscribers defined by one or more matching Triggers. A Trigger describes a filter on event attributes which should be delivered to an `addressable` object as event consumer. The events sent to broker follow a CNCF defined specification [CloudEvent](https://cloudevents.io/) which describes event data in a common way. 

![](../images/knative-triggermode.png)

In this lab, you create a `Broker` and a heartbeats event source. Events emitted from the event source are sent to the broker. And then you define a `Trigger` to subscribe a Knative service to all events in the broker.

## 1. Create a default `Broker`

A Broker represents an event bus. There could be many brokers in the platform. The easiest way to create a `Broker` is to annotate your namespace, for example the default namespace, by running the following command:

```text
kubectl label namespace default knative-eventing-injection=enabled
```

The expected output is:
```
namespace/default labeled
```

Knative will then start a few pods in your default namespace to implement broker functionalities, e.g. receiving and forwarding events. you can verify them by running the following command:
```
kubectl get pods
```

The expected output is:
```
NAME                                              READY   STATUS    RESTARTS   AGE
default-broker-filter-798df8bc75-77m2r            1/1     Running   0          43s
default-broker-ingress-5fbb869648-q4xzb           1/1     Running   0          43s
```

When these two pods are in running status, you can get your broker by running the following command:
```text
kubectl get broker
```

The expected output is:
```
NAME      READY     REASON    HOSTNAME                                   AGE
default   True                default-broker.default.svc.cluster.local   14s
```

Please notice the status `READY` of broker is `True`, which means the broker is ready for use.


## 2. Create a heartbeats event source

Now you create a heartbeats event source which produces events at the specified interval. 

Create a file named as `heartbeats.yaml` and copy the following content into it, which is the configuration of a heartbeats event source:

```code
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: heartbeats-sender
spec:
  image: docker.io/daisyycguo/heartbeats-6790335e994243a8d3f53b967cdd6398
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
  args:
    - --period=10
  env:
    - name: POD_NAME
      value: "heartbeats"
    - name: POD_NAMESPACE
      value: "default"
```

You might notice the `kind` is `ContainerSource` here, which means Knative starts a container in a Pod and passes an environment variable `SINK` to the container when it starts up. The container handles the event emiting to `sink` by itself. There are four parameters in the `spec` of a `ContainerSource`:
- image: the image URL that running inside the event source pod.
- args and env: environment and arguments to the running container.
- sink: the destination where events are sent. Here you use the default broker you just created.

Create a ContainerSource `heartbeats-sender` by running the following command:
```text
kubectl apply -f heartbeats.yaml
```

The expected output is:
```
containersource.sources.eventing.knative.dev/heartbeats-sender created
```

Check if `heartbeats-sender` has been created by running the following command:
```text
kubectl get ContainerSource
```

The expected output is:
```
NAME                AGE
heartbeats-sender   2m
```

## 3. Create a Trigger to add a subscriber to default broker

A Trigger represents a desire to subscribe to events from a specific Broker. You now create a Trigger to have the Knative service `event-display` to subscribe to the events sent to default Broker.

Create a file named as `trigger1.yaml` copying below content into it, which is the configuration of a trigger:

```code
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

You can see a `broker` and a `subscriber` are defined in its `spec`. Here the `broker` refers to the default broker, and the `subscriber` refer to the Knative service `event-display`.

Run below command to create a Trigger `mytrigger`:
```text
kubectl apply -f trigger1.yaml
```

The expected output is:
```
trigger.eventing.knative.dev/mytrigger created
```

Check if the Trigger has been created by running the following:
```text
kubectl get trigger
```

The expected output is:
```
NAME        READY     REASON    BROKER    SUBSCRIBER_URI                                    AGE
mytrigger   True                default   http://event-display.default.svc.cluster.local/   29s
```

## 4. Look at the logs of event-display

List the running Pods and see if the pod `event-display-*` is running: 
```
kubectl get pods
```

The expected output is:
```
NAME                                              READY   STATUS    RESTARTS   AGE
default-broker-filter-798df8bc75-77m2r            1/1     Running   0          4m32s
default-broker-ingress-5fbb869648-q4xzb           1/1     Running   0          4m32s
event-display-46hhp-deployment-597487d855-dm77n   2/2     Running   0          19s
heartbeats-sender-dhnz8-569967d749-8wbwt          1/1     Running   0          3m36s
```

Check the log of `event-display`:
```
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

You can see the events, similar to the following example：
```
_  CloudEvent: valid _
Context Attributes,
  SpecVersion: 0.2
  Type: dev.knative.eventing.samples.heartbeat
  Source: https://github.com/knative/eventing-sources/cmd/heartbeats/#default/heartbeats
  ID: 5fff8cd4-96c5-4fd6-b116-2a96977791e2
  Time: 2019-06-20T16:04:08.921707135Z
  ContentType: application/json
  Extensions:
    beats: true
    heart: yes
    knativehistory: default-broker-tp97m-channel-znkp9.default.svc.cluster.local
    the: 42
Transport Context,
  URI: /
  Host: event-display.default.svc.cluster.local
  Method: POST
Data,
  {
    "id": 26,
    "label": ""
  }
```

The events from heartbeat event source are printed to logs. It demonstrates that the event source `heartbeats-sender` sent the events to Broker, and the Broker forwards it to `event-display`.

Terminate the process with `ctrl + c`.

Go to [Exercise 3](../step3).

