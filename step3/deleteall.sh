kubectl delete Trigger mytrigger
kubectl delete CronJobSource cronjobs
kubectl delete ContainerSource heartbeats-sender
kubectl delete ksvc event-display
kubectl label namespace default knative-eventing-injection-
kubectl delete broker default
