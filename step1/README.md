# Subscribe to event producers by defining event sources

Event sources represent event producers which emit events from an external system. There are a list of predefined [event sources](https://knative.dev/v0.3-docs/eventing/sources/) in Knative. The events emitted from event producer will be converted into standard `CloudEvent` message by adapters before they arrives at Knative Eventing data panel.

Event source has a field `SINK` in its spec which is used to specify an `addressable` object as event consumer. For example, Knative service has an access URL defined in its `status.address.hostname` field. Knative service is able to receive and acknowledge an event delivered over HTTP to this URL address. So Knative service can be defined as an event consumer.

In this lab, we create an `CronJobSource` as event producer and specify a Knative service as the event consumer by specifying it as the `SINK` of `CronJobSource`. Thus, an event producer and an event consumer are binded in the event source definition. 

![](../images/knative-simplemode.png)

## 1. Create a Knative service `event-display`

Firstly, we create a Knative service `event-display` that prints incoming events to its log by:

```text
kubectl apply --filename service.yaml 
```

Expected output:
```
service.serving.knative.dev/event-display created
```

Run below command and check if the status `READY` of this Knative service is `True`:

```text
kubectl get ksvc
```

Expected output：
```
NAME            URL                                                                              LATESTCREATED         LATESTREADY           READY     REASON
event-display   http://event-display-default.mycluster-guoyc.au-syd.containers.appdomain.cloud   event-display-6mcvg   event-display-6mcvg   True
```

Please notice that you get a service URL here which you could use to access this service. We will use this URL in the following step.

## 2. Create a CronJobSource

CronJobSource is a predefined event source which uses an in-memory timer to produce events on the specified Cron schedule.

1. Create a cron job

    Review the content of `cronjob.yaml`, which describes a definition of a cron job:
    ```text
    cat cronjob.yaml
    ```

    Expected output:
    ```
    apiVersion: sources.eventing.knative.dev/v1alpha1
    kind: CronJobSource
    metadata:
    name: cronjobs
    spec:
      schedule: "*/1 * * * *"
      data: "{\"message\": \"Hello world!\"}"
      sink:
        apiVersion: serving.knative.dev/v1alpha1
        kind: Service
        name: event-display
    ```

    There are three parameters in the `spec` of a CronJobSource:
    - schedule: a cron format string. Here `"*/1 * * * *"` means every minute
    - data: the data to be posted to the target, in CloudEvent format.
    - sink: the URI messages will be forwarded on to. Here we use `event-display`, which is the Knative service we just created.

    Create the CronJobSource `cronjobs` by running below command:

    ```text
    kubectl apply -f cronjob.yaml
    ```

    Expected output:
    ```
    cronjobsource.sources.eventing.knative.dev/cronjobs created
    ```
    
2. Check if the cron job is created by running:

    ```text
    kubectl get cronjobsource
    ```

    Expected output:
    ```
    NAME       AGE
    cronjobs   44s
    ```

## 3. Look at the logs of `event-display`

The event source `cronjobs` will send a event message to `event-display` every minute. `event-display` will print the message to logs. You can check the running pods on Kubernetes.

1. List running Pods by:

    ```
    kubectl get pods
    ```

    Expected output:
    ```
    NAME                                              READY   STATUS    RESTARTS   AGE
    cronjob-cronjobs-tlzm9-7d4f79bbc8-krb8q           1/1     Running   0          98s
    event-display-46hhp-deployment-597487d855-7ctj5   2/2     Running   0          37s
    ```

    The pod named as `cronjob-cronjobs-*` is the cron job event source. The pod named as `event-display-*` is the Knative service `event-display` which will print event message to logs.

2. Check the logs of `event-display` by:

    ```
    kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
    ```

    Expected output:
    ```
    _  CloudEvent: valid _
    Context Attributes,
    SpecVersion: 0.2
    Type: dev.knative.cronjob.event
    Source: /apis/v1/namespaces/default/cronjobsources/cronjobs
    ID: 1e269ba0-114f-41d6-a889-dcdebaa0a73d
    Time: 2019-06-20T14:23:00.000371555Z
    ContentType: application/json
    Transport Context,
    URI: /
    Host: event-display.default.svc.cluster.local
    Method: POST
    Data,
    {
        "message": "Hello world!"
    }
    ```
    It shows that Knative service `event-display` gets event messages sent from CronJobSource `cronjobs`.

    Terminate this process by `ctrl + c`.

## 4. Delete event source

Use below command to delete `cronjobs`:

```
kubectl delete -f cronjob.yaml
```

Expected output:
```
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
```

We don't delete Knative service `event-display` because we will use it in the following labs. 

