# Exercise 1: Subscribe to event producers by defining event sources

Event sources represent event producers that emit events from an external system. See the list of predefined [event sources](https://knative.dev/v0.3-docs/eventing/sources/) in Knative. Knative services can receive and acknowledge an event delivered over HTTP, so Knative services can be defined as an event consumer.

In this lab, you create an `CronJobSource` as an event producer and specify a Knative service as the event consumer by specifying it as the `SINK` of `CronJobSource`. Thus, an event producer and an event consumer are bound in the event source definition. 

![](../images/knative-simplemode.png)

## 1. Create a Knative service `event-display`

First of all, you create a Knative service `event-display` that prints incoming events to its log.

Create a file named as `service.yaml` copying the following content into it, which is the configuration of a Knative service:

```code
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
```

Create the service by applying below command:
```text
kubectl apply --filename service.yaml 
```

Here is the expected output:
```
service.serving.knative.dev/event-display created
```

Run the following command and check if the status `READY` of this Knative service is `True`:

```text
kubectl get ksvc
```

Here is the expected output：
```
NAME            URL                                                                              LATESTCREATED         LATESTREADY           READY     REASON
event-display   http://event-display-default.mycluster-guoyc.au-syd.containers.appdomain.cloud   event-display-6mcvg   event-display-6mcvg   True
```

Note that you get a service URL here which you could use to access this service. We will use this URL in the following step.

## 2. Create a CronJobSource

CronJobSource is a predefined event source that uses an in-memory timer to produce events on the specified Cron schedule.

1. Create a cron job.

    Create a file named as `cronjob.yaml` copying the following content into it, which is the configuration of a cron job :

    ```code
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

    Please pay attention to the parameters in the `spec` of this CronJobSource:
    - schedule: a [cron](https://en.wikipedia.org/wiki/Cron) format string. Here `"*/1 * * * *"` means every minute
    - data: the data to be posted to the target, in json format.
    - sink: the URI messages will be forwarded on to. Here we `Kind` and `name` to specify a Knative Service `event-display`, which we just created.

    Create the CronJobSource `cronjobs` by running the following command:

    ```text
    kubectl apply -f cronjob.yaml
    ```

    The expected output is:
    ```
    cronjobsource.sources.eventing.knative.dev/cronjobs created
    ```
    
2. Check if the cron job is created by running:

    ```text
    kubectl get cronjobsource
    ```

    The expected output is:
    ```
    NAME       AGE
    cronjobs   44s
    ```

## 3. Look at the logs of `event-display`

The event source `cronjobs` sends an event to `event-display` every minute. `event-display` prints the events to its logs (stdout). You can check the running pods on Kubernetes.

1. List running Pods by running the following command:

    ```
    kubectl get pods
    ```

    Expected output:
    ```
    NAME                                              READY   STATUS    RESTARTS   AGE
    cronjob-cronjobs-tlzm9-7d4f79bbc8-krb8q           1/1     Running   0          98s
    event-display-46hhp-deployment-597487d855-7ctj5   2/2     Running   0          37s
    ```

    The pod `cronjob-cronjobs-*` is the cron job event source. The pod `event-display-*` is the Knative service `event-display` which will print event message to logs.

2. Check the logs of `event-display` by running the following command:

    ```
    kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
    ```

    The expected output is:
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

    Terminate this process with `ctrl + c`.

## 4. Delete the event source

Use the following command to delete `cronjobs`:

```
kubectl delete -f cronjob.yaml
```

The expected output is:
```
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
```

You don't delete the Knative service `event-display` because you will use it in the following lab exercises. 

Go to [Exercise 2](../step2).
