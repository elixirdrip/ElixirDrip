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

echo "[SCRIPT] Successfully pushed image tagged with ${COMMIT}"

cat deploy/elixir-drip-migrations-prod.yml | sed "s/\${BUILD_TAG}/${COMMIT}/g" > travis-migrations-prod.yml

echo "[SCRIPT] Replaced the BUILD_TAG in the migrations template"

kubectl -n ${ENVIRONMENT} create -f travis-migrations-prod.yml

echo "[SCRIPT] Applied the migrations template with the new image. Will wait 30 secs..."
sleep 30
echo "[SCRIPT] Now onto the deployment template."

cat deploy/elixir-drip-deployment-prod.yml | sed "s/\${BUILD_TAG}/${COMMIT}/g" > travis-deployment-prod.yml

echo "[SCRIPT] Replaced the BUILD_TAG in the deployment template"

kubectl -n ${ENVIRONMENT} apply -f travis-deployment-prod.yml

echo "[SCRIPT] Applied the deployment template with the new image"

echo "[SCRIPT] Success!"
