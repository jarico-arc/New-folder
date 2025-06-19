# Day-2 Run-Book

This run-book documents common operational tasks and the commands to execute them.

| Action               | Steps                                                                                         |
|----------------------|-----------------------------------------------------------------------------------------------|
| Minor YB Upgrade     | ```bash
helm repo update yugabytedb/yugabyte
helm upgrade yb-prod yugabytedb/yugabyte \
  -n yb-prod \
  --set image.tag=<new-version>
``` |
| Add Capacity         | 1. Edit `terraform/applications.tf` (or `yugabyte_values.yaml`): set `replicaCount.tserver`  
 2. `terraform apply` **or**  
 ```bash
helm upgrade yb-prod yugabytedb/yugabyte \
  -n yb-prod -f yugabyte_values.yaml
``` |
| Node Drain           | ```bash
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
kubectl uncordon <node-name>
```  |
| Restore Table        | ```bash
yb-admin restore_snapshot \
  --snapshot_id=<snapshot-id>
``` |
| Rotate TLS Certs     | 1. Generate new certs (e.g. via cert-manager or openssl)  
 2. Update Kubernetes secret:  
 ```bash
kubectl -n yb-prod create secret tls yb-tls --key=key.pem --cert=cert.pem --dry-run=client -o yaml | kubectl apply -f -
```  
 3. `helm upgrade yb-prod yugabytedb/yugabyte -n yb-prod -f yugabyte_values.yaml` |
| Connector Stuck      | ```bash
kubectl -n kafka rollout restart deployment/debezium-gke
# Inspect DLQ topic:<br/>kcat -b rp-0.rp-headless.kafka.svc.cluster.local:9092 -t <topic>-dlq -C
``` | 