#!/bin/bash

#	https://minikube.sigs.k8s.io/docs/start/
#	https://github.com/jaegertracing/jaeger-operator
minikube start --addons=ingress

#	https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace
kubectl create namespace telemetry

#	https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
#	https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/
#	https://opentelemetry.io/docs/kubernetes/operator/automatic/
#kubectl annotate namespace default instrumentation.opentelemetry.io/inject-dotnet='true'

#minikube ssh << EOF
#sudo sysctl fs.inotify.max_user_instances=8192
#EOF

#	https://opentelemetry.io/docs/instrumentation/net/getting-started/
#	https://learn.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=linux&pivots=dotnet-7-0

#	https://opentelemetry.io/docs/getting-started/ops/
# 	https://cert-manager.io/docs/installation/helm/
#	https://cert-manager.io/docs/configuration/selfsigned/
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml --namespace telemetry

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace telemetry \
  --version v1.13.1 \
  # --set installCRDs=true

#	https://opentelemetry.io/docs/kubernetes/operator/
#	https://opentelemetry.io/docs/kubernetes/helm/operator/
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otelop --namespace telemetry open-telemetry/opentelemetry-operator --values ./otelop.yaml \
  --set admissionWebhooks.certManager.enabled=false \
  --set admissionWebhooks.certManager.autoGenerateCert=true \
  --set admissionWebhooks.certManager.create=false

sleep 30

#	https://opentelemetry.io/docs/kubernetes/helm/collector/
#	https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector
#	https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-collector/values.yaml
#	https://opentelemetry.io/docs/kubernetes/collector/components/
#	https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/exporter/lokiexporter/README.md
#	https://grafana.com/docs/opentelemetry/collector/send-logs-to-loki/kubernetes-logs/
#	https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/filelogreceiver/README.md
#	https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/pkg/stanza/docs/operators/recombine.md
#	https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/exporter/lokiexporter/example/otelcol.yaml
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otelcol --namespace telemetry open-telemetry/opentelemetry-collector --values ./otelcol.yaml \
   --set mode=daemonset

sleep 30 

#	https://opentelemetry.io/docs/kubernetes/operator/automatic/
#	https://opentelemetry.io/docs/instrumentation/net/automatic/config/
#	https://github.com/open-telemetry/opentelemetry-collector/blob/main/config/configtls/README.md
#	https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main
#	https://opentelemetry.io/docs/collector/trace-receiver/
#	https://opentelemetry.io/docs/instrumentation/net/automatic/instrumentations/
#	https://opentelemetry.io/docs/demo/architecture/
kubectl apply -f - <<EOF
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: otelins
  namespace: default
spec:
  exporter:
    endpoint: otelcol-opentelemetry-collector:4318
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: "1"
  env:
    dotnet:
	OTEL_LOG_LEVEL: debug
EOF

#	https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
#kubectl get crd

sleep 30

#	https://bitnami.com/stack/aspnet-core/helm
#helm upgrade --install my-release oci://registry-1.docker.io/bitnamicharts/aspnet-core --values ./aspnet-core.yaml

#	https://bitnami.com/stack/nginx/helm
#helm upgrade --install my-release oci://registry-1.docker.io/bitnamicharts/nginx

#	https://bitnami.com/stack/wordpress/helm
#helm install my-release oci://registry-1.docker.io/bitnamicharts/wordpress

#	https://github.com/dotnet/dotnet-docker/blob/main/samples/kubernetes/manual-deployment/README.md
#kubectl create deployment dotnet-app --namespace telemetry --image mcr.microsoft.com/dotnet/samples:aspnetapp
#kubectl expose deployment dotnet-app --type=ClusterIP --port=8080

#	https://artifacthub.io/packages/helm/grafana/loki-stack
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

helm upgrade --install loki \
    --namespace telemetry grafana/loki-stack \
    --set fluent-bit.enabled=false \
    --set promtail.enabled=false \
    --set grafana.enabled=true \
    --set prometheus.enabled=false

#	https://github.com/jaegertracing/jaeger-operator
#	https://www.jaegertracing.io/docs/1.50/operator/
#helm repo add jaegertracing https://jaegertracing.github.io/helm-charts

#helm repo update

#helm upgrade --install jaeger-operator jaegertracing/jaeger-operator -n default 

#sleep 30

#	https://github.com/jaegertracing/jaeger-operator/tree/main/examples
#kubectl apply -f - <<EOF
#apiVersion: jaegertracing.io/v1
#kind: Jaeger
#metadata:
#  name: jaeger
#  namespace: default
#EOF
