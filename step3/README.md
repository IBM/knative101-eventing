# Exercise 3: Define a filter

Multiple kinds of events can be sent to the same broker. If you are interested in a specific type of event, you can use the `Filter` configuration option in the Trigger to subscribe to a specific type of event.

Here in this exercise, you create a second event source `CronJobs` and send events to default broker. Then you use `Filter` to subscribe to the specific type of event.

![](../images/knative-filtermode.png)

## 1. Create another event source CronJobs

Now you create an event source `cronjobs` to send events to default broker.

Create a file named as `cronjob.yaml` copying the following content into it, which is the configuration of a cron job event source:

```code
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjobs
spec:
  schedule: "*/1 * * * *"
  data: "{\"message\": \"Hello world!\"}"
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
```

Please pay attention to the `SINK` which refers to the default broker.

Create the cron job event source by applying the following command:
```text
kubectl apply -f cronjob.yaml
```

The expected output is:
```
cronjobsource.sources.eventing.knative.dev/cronjobs created
```

Get the event source by applying the following command:
```
kubectl get CronJobSource
```

The expected output is:
```
NAME       AGE
cronjobs   23s
```

Remember that you already have heartbeat events being sent to the default Broker. If you add another event source, `CronJobs`, it also sends events to default broker, and you get two kinds of events in the Broker. 

Check the logs of `event-display`, and you can see that both events from `heartbeats` and `cronjob`:

```text
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

The expected output looks like the following example:

```text
☁️  CloudEvent: valid ✅
Context Attributes,
  SpecVersion: 0.3
  Type: dev.knative.cronjob.event
  Source: /apis/v1/namespaces/default/cronjobsources/cronjobs
  ID: 14d13807-1ef6-4ffe-ad54-abfe9f9411a8
  Time: 2019-09-04T08:29:00.009199062Z
  DataContentType: application/json
  Extensions:
    knativehistory: default-kn2-trigger-kn-channel.default.svc.cluster.local
    kn00timeinflight: 2019-09-04T08:29:00.013373521Z
Transport Context,
  URI: /
  Host: event-display.default.svc.cluster.local
  Method: POST
Data,
  {
    "message": "Hello world!"
  }

☁️  CloudEvent: valid ✅
Context Attributes,
  SpecVersion: 0.3
  Type: dev.knative.eventing.samples.heartbeat
  Source: https://github.com/knative/eventing-sources/cmd/heartbeats/#default/heartbeats
  ID: 78986ebe-be65-44b9-87d1-602718ff5514
  Time: 2019-09-04T08:29:00.361296485Z
  DataContentType: application/json
  Extensions:
    kn00timeinflight: 2019-09-04T08:29:00.361821752Z
    knativehistory: default-kn2-trigger-kn-channel.default.svc.cluster.local
    beats: true
    heart: yes
    the: 42
Transport Context,
  URI: /
  Host: event-display.default.svc.cluster.local
  Method: POST
Data,
  {
    "id": 17,
    "label": ""
  }
```

Terminate this process with `ctrl+c`.

## 2. Define the filter in a trigger

Now you define a trigger with a filter.

Create a file named as `trigger2.yaml` copying the following content into it, which is the configuration of a trigger with filter:

```code
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  broker: default
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

Comparing to the old version, the new trigger has an attribute called `filter`. In the `filter`, you define an event type `dev.knative.cronjob.event` which exactly matches the event source `CronJobs`. By adding `filter`, the Broker will only forward those events matching the event type to the subscriber.

Now you create this new `mytrigger` with filter by applying the new version of the yaml file:

```text
kubectl replace -f trigger2.yaml
```

The expected output is:
```
trigger.eventing.knative.dev/mytrigger replaced
```

Check the logs of `event-display`, you will see that only events from `cronjob` now:

```text
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

Terminate this process with `ctrl+c`.

## 3. Delete all

Create a file named as `deleteall.sh` copying the following content into it.

```code
kubectl delete Trigger mytrigger
kubectl delete CronJobSource cronjobs
kubectl delete ContainerSource heartbeats-sender
kubectl delete ksvc event-display
kubectl label namespace default knative-eventing-injection-
kubectl delete broker default
```

Run the script to delete all the artifacts you created in this tutorial by running the following command:
```
source deleteall.sh
```

Now you have finished the complete hands-on part of this tutorial. You are ready to try this work on your own.