#!/bin/bash
set -e

NAMESPACE="gpu-platform"
DIR="$(cd "$(dirname "$0")" && pwd)/manifests"

case "${1:-deploy}" in
  deploy)
    echo "==> Deploying to namespace: $NAMESPACE"
    kubectl apply -f "$DIR/00-namespace.yaml"
    kubectl apply -f "$DIR/01-platform-config.yaml"
    kubectl apply -f "$DIR/01-configmaps.yaml"
    kubectl apply -f "$DIR/02-healthy-services.yaml"
    echo ""
    echo "==> Deploying model servers..."
    kubectl apply -f "$DIR/10-deploy-novai.yaml"
    kubectl apply -f "$DIR/11-deploy-acme.yaml"
    kubectl apply -f "$DIR/12-deploy-vertex.yaml"
    kubectl apply -f "$DIR/13-deploy-dataflow.yaml"
    kubectl apply -f "$DIR/14-deploy-quantum.yaml"
    echo ""
    echo "==> Deploying observability stack..."
    kubectl apply -f "$DIR/20-loki.yaml"
    kubectl apply -f "$DIR/22-grafana.yaml"
    echo ""
    echo "==> Done."
    echo "    kubectl get pods -n $NAMESPACE"
    ;;
  teardown|delete|destroy)
    echo "==> Tearing down namespace: $NAMESPACE"
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    echo "==> Done"
    ;;
  status)
    echo "==> Pod status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    echo ""
    echo "==> Recent events:"
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -20
    ;;
  *)
    echo "Usage: $0 {deploy|teardown|status}"
    exit 1
    ;;
esac
