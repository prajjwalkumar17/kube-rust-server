#!/usr/bin/env bash
set -e

IMAGE_NAME="localhost/kube-rust-server:v1"
TAR_FILE="kube-rust-server.tar"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

echo "Building Rust server with Podman..."
podman build -t $IMAGE_NAME -f Containerfile .

echo "Saving image to tar file..."
podman save $IMAGE_NAME -o $TAR_FILE

echo "Loading image into containerd..."
# Use sudo if needed
if command_exists ctr; then
    # For vanilla containerd
    sudo ctr -n k8s.io images import $TAR_FILE
elif command_exists k3s; then
    # For k3s
    sudo k3s ctr images import $TAR_FILE
elif command_exists nerdctl; then
    # For nerdctl
    sudo nerdctl -n k8s.io load < $TAR_FILE
elif command_exists crictl; then
    # For crictl
    sudo crictl images pull $IMAGE_NAME
else
    echo "No containerd CLI tool found. Please manually load the image into your container runtime."
    echo "The tar file has been saved as $TAR_FILE"
fi

echo "Creating namespace and deploying to Kubernetes..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/rust-server -n rust-server

echo "Deployment complete! Your server should be accessible at:"
echo "  - http://192.168.29.100:8080"
echo "  - http://rust-server.home (if DNS is properly configured)"

echo "To check the status of your pods:"
echo "kubectl get pods -l app=rust-server -n rust-server"

echo "To check if the image is available in the cluster:"
echo "kubectl describe pod -n rust-server | grep Image"

echo "To check the status of the Ingress resource:"
echo "kubectl get ingress -n rust-server"
