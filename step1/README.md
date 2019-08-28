# Enable Knative add-on on IBM Cloud Kubernetes Service

Managed Knative add-on on IBM Cloud Kubernetes Service is an easy way to enhance your Kubernetes cluster with Serverless capabilities. It will install IBM tested version of Knative and Istio directly on your IBM Cloud Kubernetes cluster.

## Prerequisites

* A IBM Kubernetes Service cluster is provisioned, at least with 2 worker nodes.
* IBM Cloud CLI installed.
* Kubernetes CLI installed.

## 第一步：使用IBM Cloud命令行工具安装

在CloudShell窗口中执行下面的命令，这个命令会自动安装Istio和Knative。

```text
ibmcloud ks cluster-addon-enable knative --cluster $MYCLUSTER
```

当提示`Enable istio? [y/N]>`输入y。期待输出：
```
Enabling add-on knative for cluster knative-guoyc...
The istio add-on version 1.1.7 is required to enable the knative add-on. Enable istio? [y/N]> y
OK
```
整个安装过程大约需要几分钟，请耐心等待，可以通过下面步骤检查安装进程。

## 第二步：检查安装后的Knative

在CloudShell窗口中执行下面的命令，观察Knative的安装过程，以及安装的组件。

1. 列出所有的名称空间，其中knative-\*以及istio-system是安装的名称空间：

   ```text
   kubectl get namespace
   ```
   期待输出：
   ```
   NAME                 STATUS    AGE
   default              Active    30m
   ibm-cert-store       Active    20m
   ibm-system           Active    28m
   istio-system         Active    5m20s
   knative-build        Active    5m14s
   knative-eventing     Active    5m14s
   knative-monitoring   Active    5m14s
   knative-serving      Active    5m14s
   knative-sources      Active    5m14s
   kube-public          Active    30m
   kube-system          Active    30m
   ```

2. Istio需要先于Knative安装。观察istio-system下面的pod，直到都进入running状态：

   ```text
   watch kubectl get pods -n istio-system
   ```
   期待输出：
   ```
   NAME                                     READY     STATUS    RESTARTS   AGE
   cluster-local-gateway-5897bf4bdd-fr544   1/1       Running   0          4m51s
   istio-citadel-6f58d87c48-b9v5f           1/1       Running   0          5m32s
   istio-egressgateway-5ffbbb468-c5t6j      1/1       Running   0          5m32s
   istio-galley-65bcc9b6f7-czqmp            1/1       Running   0          5m32s
   istio-ingressgateway-85787c5976-2vwsp    1/1       Running   0          5m32s
   istio-pilot-77d74c888-nqzbq              2/2       Running   0          5m32s
   istio-policy-7f79dbbdc7-2tffd            2/2       Running   5          5m32s
   istio-sidecar-injector-68c4dc865-p8r7v   1/1       Running   0          5m31s
   istio-telemetry-697d4cf64-vmgzf          2/2       Running   6          5m31s
   prometheus-7d6678d744-swb6q              1/1       Running   0          5m31s
   ```

   输入`ctrl+c`结束观察进程。

1. Knative将安装完Istio之后开始安装。观察knative-serving下面的pod，直到都进入running状态：

   ```text
   watch kubectl get pods -n knative-serving
   ```
   期待输出：
   ```
   NAME                                     READY     STATUS    RESTARTS   AGE
   activator-54f5ff5cc7-6vrlt               2/2       Running   1          4m33s
   autoscaler-6f4965c9bd-w997f              2/2       Running   0          4m33s
   controller-5b9bfd9594-d9bsv              1/1       Running   0          4m33s
   networking-certmanager-d8c475984-l97j8   1/1       Running   0          4m33s
   networking-istio-76d4b55fd4-cf6q5        1/1       Running   0          4m33s
   webhook-75bcf549-dq587                   1/1       Running   0          4m33s
   ```

   输入`ctrl+c`结束观察。

恭喜您已经完成了Knative的安装！可以进行下面的实验了。

## More information

1. Run below command to uninstall knative add-on and istio add-on.

   ```text
   ibmcloud ks cluster-addon-disable knative --cluster $MYCLUSTER
   ibmcloud ks cluster-addon-disable istio --cluster $MYCLUSTER
   ```



