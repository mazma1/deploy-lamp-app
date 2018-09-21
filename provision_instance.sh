#!/usr/bin/env bash

# script to provision a Compute Engine on GCP

# exit when a command fails
set -o errexit

# exit if previous command returns a non 0 status
set -o pipefail


PROJECT_NAME=$1

provision_instance() {
  echo 'About to provision host instance......'

  gcloud compute instances create $PROJECT_NAME \
    --zone europe-west3-b \
    --machine-type f1-micro

  gcloud compute instances add-tags $PROJECT_NAME \
    --tags lamp

  echo 'Successfully provisioned host instance.'
}


copy_deployment_script() {
  echo 'About to copy local deployment script to new instance...'

  gcloud compute scp './deploy_app.sh' $PROJECT_NAME:/tmp/deploy_app.sh

  gcloud compute ssh $PROJECT_NAME --zone europe-west3-b \
    --command "sudo mv /tmp/deploy_app.sh /home/deploy_app.sh"

  echo 'Successfully copied deployment script.'
}


execute_deployment_script() {
  echo 'About to begin stack setup and app deployment...'

  gcloud compute ssh $PROJECT_NAME --zone europe-west3-b \
    --command "chmod +x /home/deploy_app.sh"

  gcloud compute ssh $PROJECT_NAME --zone europe-west3-b \
    --command "/home/deploy_app.sh"
}


main() {
  provision_instance
  copy_deployment_script
  execute_deployment_script
}

main "$@"
