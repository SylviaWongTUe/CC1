gcloud compute project-info describe \
  --format="value(commonInstanceMetadata[items][ssh-keys])"

ssh_key=$(cat ~/.ssh/id_rsa.pub)

touch gcp_key.pub 

echo 'pdcnguyen':$ssh_key > gcp_key.pub

gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=gcp_key.pub

gcloud compute firewall-rules create cc-rules --allow tcp:22,icmp  --source-tags=cloud-computing

gcloud compute instances create cc-instance --image-family=ubuntu-1804-lts --image-project=ubuntu-os-cloud --zone=europe-west3-c --machine-type=e2-standard-2 --tags=cloud-computing

ins_state=$(gcloud compute instances describe cc-instance --zone=europe-west3-c --format="value(status)")

while [ $ins_state != "RUNNING" ]
do
    sleep 5

ins_state=$(gcloud compute instances describe cc-instance --zone=europe-west3-c --format="value(status)")

done

yes | gcloud compute disks resize cc-instance --zone=europe-west3-c --size 100
