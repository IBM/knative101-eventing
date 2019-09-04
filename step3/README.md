# Define a Filter

Multiple kinds of events can be sent to a same broker. If you are interested in a specific event source, you can use Filter in Trigger to subsribe a specific type of events.

Here we create a second event source `CronJobs` and send events to default broker. Then we use Filter to subscribe to a specific type of events.

![](../images/knative-filtermode.png)

## Step 1. Create another event source CronJobs

Create another event source `cronjobs` by:

```text
$ kubectl apply -f cronjob.yaml
cronjobsource.sources.eventing.knative.dev/cronjobs created
$ kubectl get CronJobSource
NAME       AGE
cronjobs   23s
```

Remember we already have heart beat events in the default Broker. If we add another event source `CronJobs` who also sends events to default broker, we will get two kinds of events in the Broker. 

Check the logs of `event-display`, you can see that both messages from `heartbeats` and `cronjob`:

```text
$ kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

Expected output looks like:

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

Terminate this process by `ctrl+c`.

## Step 2. Define filter in trigger

Check a filter to the trigger `mytrigger` yaml file:

```text
$ cat trigger2.yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

Create a new `mytrigger` with filter by applying the new version of yaml file:

```text
$ kubectl replace -f trigger2.yaml
trigger.eventing.knative.dev/mytrigger replaced
```

Check the new version of `mytrigger` that filter has been configured:

```text
$ kubectl get trigger mytrigger -o yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"eventing.knative.dev/v1alpha1","kind":"Trigger","metadata":{"annotations":{},"name":"mytrigger","namespace":"default"},"spec":{"filter":{"sourceAndType":{"type":"dev.knative.cronjob.event"}},"subscriber":{"ref":{"apiVersion":"serving.knative.dev/v1alpha1","kind":"Service","name":"event-display"}}}}
  creationTimestamp: 2019-06-18T11:05:06Z
  generation: 1
  name: mytrigger
  namespace: default
  resourceVersion: "26695"
  selfLink: /apis/eventing.knative.dev/v1alpha1/namespaces/default/triggers/mytrigger
  uid: ee38938a-91b8-11e9-9c6b-4e0b3deb5d31
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
status:
  conditions:
  - lastTransitionTime: 2019-06-18T11:05:06Z
    status: "True"
    type: Broker
  - lastTransitionTime: 2019-06-18T11:05:07Z
    status: "True"
    type: Ready
  - lastTransitionTime: 2019-06-18T11:05:07Z
    status: "True"
    type: Subscribed
  subscriberURI: http://event-display.default.svc.cluster.local/
```

Check the logs of `event-display`, you will see that only messages from `cronjob` now:

```text
$ kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

Terminate this process by `ctrl+c`.

## Step 3. Delete all

Run below command to delete all the artifacts you craeted in this tutorial.

```
source deleteall.sh
```

Expected output:
```
trigger.eventing.knative.dev "mytrigger" deleted
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
containersource.sources.eventing.knative.dev "heartbeats-sender" deleted
service.serving.knative.dev "event-display" deleted
daisyyings-mbp:step3 Daisy$ source deleteall.sh
```