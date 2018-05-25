#!/bin/bash

COMMIT="$1"
ENVIRONMENT="$2"
echo "Deploying ${COMMIT} to ${ENVIRONMENT}"

echo ${GOOGLE_CLOUD_DEPLOY_CREDENTIALS} | base64 --decode > ${HOME}/travis-ci-k8s-deployment-creds.json

gcloud auth activate-service-account --key-file ${HOME}/travis-ci-k8s-deployment-creds.json

ZONE=europe-west1-b
PROJECT_ID=intense-talent-188323
CLUSTER=elixir-drip-prod-cluster

gcloud --quiet config set compute/zone ${ZONE}
gcloud --quiet config set project ${PROJECT_ID}
gcloud --quiet config set container/cluster ${CLUSTER}
gcloud --quiet container clusters get-credentials ${CLUSTER}

yes | gcloud auth configure-docker

docker push gcr.io/${PROJECT_ID}/elixir-drip-prod:${COMMIT}

kubectl -n ${ENVIRONMENT} get pods

kubectl -n ${ENVIRONMENT} set image deployment/elixir-drip elixir-drip-prod=gcr.io/intense-talent-188323/elixir-drip-prod:${COMMIT}

echo "Success!"
