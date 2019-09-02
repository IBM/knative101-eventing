# Link a service to an Event importer

Event sources in Knative are defined by Kubernetes Custom Resources. There are a list of predefined event sources in Knative. Creating an event source importer and using `SINK` to link to a Knative service is the simpliest way to consume an event. Here we use `Cronjob` as a sample.

![](../images/knative-simplemode.png)

## 1. Create a Knative service `event-display`

Firstly, we create a Knative service `event-display` by:

```text
kubectl apply --filename service.yaml 
```

Expected output:
```
Service 'event-display' successfully created in namespace 'default'.
```

Run below command and check if the status `READY` of this Knative service is `True`:

```text
kubectl get ksvc
```

Expected output：
```
NAME            DOMAIN                                                                   GENERATION   AGE   CONDITIONS   READY   REASON
event-display   event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            32s   3 OK / 3     True
```

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

## 步骤三：检查event-display的日志

事件源`cronjobs`每隔1分钟，就会发送一条事件给`event-display`，`event-display`将把它打印到日志中。在这个逻辑的背后，是两个Kubernetes Pod在运行。

1. 查看运行Pod

    下面命令将列出所有运行的Pod：
    ```
    kubectl get pods
    ```

    期待输出：
    ```
    NAME                                              READY   STATUS    RESTARTS   AGE
    cronjob-cronjobs-tlzm9-7d4f79bbc8-krb8q           1/1     Running   0          98s
    event-display-46hhp-deployment-597487d855-7ctj5   2/2     Running   0          37s
    ```

    其中，`cronjob-cronjobs-`为前缀的Pod，就是定时事件源，而`event-display-`为前缀的Pod，则是事件消息的展示应用。

2. 查看`event-display`的日志

    下面我们查看`event-display`的日志：
    ```
    kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
    ```

    能看到日志显示的CloudEvent标准消息如下面所示：
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
    这说明了`cronjobs`创建后，定时产生CloudEvent标准格式的事件消息，这个消息被`event-display`接收并打印在日志中。

    观察完毕，使用`ctrl + c`结束进程。

## 步骤四：删除事件源

现在我们先删除`cronjobs`，因为接下来的实验我们将采用其他方法管理事件和订阅：

```
kubectl delete -f cronjob.yaml
```

期待输出：
```
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
```

`event-display`并没有删除，我们还将在下面的实验中用到它。但因为它是Serverless的服务，一段时间不被调用将会被平台自动收回。

```
kubectl get pods
```

可能的输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Running   0          3m46s
```
或者
```
NAME                                              READY   STATUS        RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Terminating   0          4m14s
```
或者
```
No resources found.
```

