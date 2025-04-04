#!/bin/sh
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo $SCRIPT_DIR
# Replace with your container registry
REPO="ghcr.io/lake-of-dreams"

#  Create Kind cluster
kind delete cluster --name lrademo
kind create cluster --name lrademo

#  Install optional Ingress Controller
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

# Install Oracle Transaction Manager for Microservices
kubectl apply -f ./otmm.yaml

# Build Microservice images
git clone https://github.com/oracle-samples/microtx-samples.git
cd ${SCRIPT_DIR}/microtx-samples/lra/lrademo/flight-springboot
podman image build --arch=amd64 -t=$REPO/flight-springboot:1.0
podman push ${REPO}/flight-springboot:1.0

cd ${SCRIPT_DIR}/microtx-samples/lra/lrademo/hotel-springboot
podman image build --arch=amd64 -t=${REPO}/hotel-springboot:1.0 .
podman push ${REPO}/hotel-springboot:1.0

cd ${SCRIPT_DIR}/microtx-samples/lra/lrademo/trip-manager-springboot
podman image build --arch=amd64 -t=${REPO}/trip-manager-springboot:1.0 .
podman push ${REPO}/trip-manager-springboot:1.0

# Install microservices
helm upgrade --install sampleappslra --namespace otmm ${SCRIPT_DIR}/microtx-samples/lra/helmcharts/sampleappslrak8s/ --values ${SCRIPT_DIR}/microtx-samples/lra/helmcharts/sampleappslrak8s/values.yaml \
    --set sampleappslra.tripmanager.image=${REPO}/trip-manager-springboot:1.0 \
    --set sampleappslra.hotel.image=${REPO}/hotel-springboot:1.0 \
    --set sampleappslra.flight.image=${REPO}/flight-springboot:1.0

# Run a pod to access microservices
kubectl run mycurlpod --image=badouralix/curl-jq -i --tty -- sh

curl http://hotel.otmm.svc.cluster.local:8082/hotelService/api/hotel
curl http://flight.otmm.svc.cluster.local:8083/flightService/api/flight
curl http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip

id=$(echo $(
    curl -s -X POST -d '' http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip?hotelName=Alpha &
    flightNumber=BA123
) | jq -r .id)
decodedId=$(echo ${id} | base64 -d)

curl http://flight.otmm.svc.cluster.local:8083/flightService/api/flight
curl http://hotel.otmm.svc.cluster.local:8082/hotelService/api/hotel

curl --location --request PUT -H "Long-Running-Action: $decodedId" -d '' http://trip-manager.otmm.svc.cluster.local:8081/trip-service/api/trip/$id
