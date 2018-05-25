#!/bin/bash

COMMIT="$1"
ENVIRONMENT="$2"
echo "Deploying ${COMMIT} to ${ENVIRONMENT}"

# TODO: remove
docker images

echo $GOOGLE_CLOUD_DEPLOY_CREDENTIALS | base64 --decode > ${HOME}/travis-ci-k8s-deployment-creds.json

gcloud auth activate-service-account --key-file ${HOME}/travis-ci-k8s-deployment-creds.json

ZONE=europe-west1-b
PROJECT_ID=intense-talent-188323
CLUSTER=elixir-drip-prod-cluster

# TODO: add --quiet after gcloud
gcloud config set compute/zone $ZONE
gcloud config set project $PROJECT_ID
gcloud config set container/cluster $CLUSTER
gcloud container clusters get-credentials $CLUSTER

gcloud docker -- push gcr.io/${PROJECT_ID}/elixir-drip-prod:${COMMIT}

echo "Success!"
