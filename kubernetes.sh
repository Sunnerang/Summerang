#!/bin/bash

# Function to deploy an application
deploy_application() {
    local app_name=$1
    local image_name=$2
    kubectl create deployment $app_name --image=$image_name
    kubectl expose deployment $app_name --port=80 --type=NodePort
}

# Function to scale an application
scale_application() {
    local app_name=$1
    local replicas=$2
    kubectl scale deployment $app_name --replicas=$replicas
}

# Function to update an application's image
update_application_image() {
    local app_name=$1
    local new_image=$2
    kubectl set image deployment/$app_name $app_name=$new_image
}

# Function to delete an application
delete_application() {
    local app_name=$1
    kubectl delete deployment $app_name
    kubectl delete service $app_name
}

# Main control flow

# Determine the context/environment
if [ "$KUBE_CONTEXT" == "local" ]; then
    # Use local images for local cluster
    deploy_application "nginx" "nginx:latest"
else
    # Use non-local images for non-local cluster
    deploy_application "nginx" "nginx"
fi

# Scale the application
scale_application "nginx" 3

# Update the application image
if [ "$KUBE_CONTEXT" == "local" ]; then
    # Use local images for local cluster
    update_application_image "nginx" "nginx:1.19.8"
else
    # Use non-local images for non-local cluster
    update_application_image "nginx" "nginx:1.19.8"
fi

# Delete the application
delete_application "nginx"

