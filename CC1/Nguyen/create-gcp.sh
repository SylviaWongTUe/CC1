# create copy of public key and modify accordingly
gcloud compute project-info describe \
  --format="value(commonInstanceMetadata[items][ssh-keys])"

ssh_key=$(cat ~/.ssh/id_rsa.pub)

touch gcp_key.pub 

echo 'nguyen@nguyensPC':$ssh_key > gcp_key.pub


# upload key
gcloud compute project-info add-metadata \
  --metadata-from-file=ssh-keys=gcp_key.pub

# create firewall rules
gcloud compute firewall-rules create cc-rules \
  --allow tcp:22,icmp \
  --source-tags=cloud-computing

# create instance
gcloud compute instances create cc-instance \
  --image-family=ubuntu-1804-lts \
  --image-project=ubuntu-os-cloud \
  --zone=europe-west3-c \
  --machine-type=e2-standard-2 \
  --tags=cloud-computing

# get instance state
ins_state=$(gcloud compute instances describe cc-instance --zone=europe-west3-c --format="value(status)")

# check instance state for ready
while [ $ins_state != "RUNNING" ]
do
    sleep 5

ins_state=$(gcloud compute instances describe cc-instance --zone=europe-west3-c --format="value(status)")

done

# resize instance disk
yes | gcloud compute disks resize cc-instance --zone=europe-west3-c --size 100



crontab -l > mycron && echo "*/30 * * * * /home/nguyen/bench.sh >> /home/nguyen/bench.csv 2>&1" >> mycron && crontab mycron && rm mycron