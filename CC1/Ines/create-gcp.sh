#!/bin/bash

#image for Ubuntu 18.04 server
image=ubuntu-1804-bionic-v20221018

#### 1)
# create public key if necessary
ssh-keygen -q -t rsa -C "id_rsa" -f id_rsa -N "" <<< n

# get current ssh-keys and store in file
#gcloud compute project-info describe \
#  --format="value(commonInstanceMetadata[items][ssh-keys])" > $PWD/ssh-keys.txt

# get content of public key
public_key=$(cat $PWD/id_rsa.pub)

# append key to file
echo "id_rsa:$public_key" >> $PWD/ssh-keys.txt


#### 2)
# upload keys to project metadata
gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=$PWD/ssh-keys.txt

# delete text file with ssh-keys
rm $PWD/ssh-keys.txt


#### 3)
# allow SSH traffic
gcloud compute firewall-rules create cloud-computing-ssh \
    --action=ALLOW \
    --direction=INGRESS \
    --priority=1000 \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=cloud-computing

# allow ICMP traffic
gcloud compute firewall-rules create cloud-computing-icmp \
    --action=ALLOW \
    --direction=INGRESS \
    --priority=1000 \
    --rules=icmp \
    --source-ranges=0.0.0.0/0 \
    --target-tags=cloud-computing


#### 4)
# create instance
gcloud compute instances create cloudcomputing \
	--image-project=ubuntu-os-cloud \
	--image=$image \
	--machine-type=e2-standard-2 \
	--tags=cloud-computing \
	--zone=europe-west3-a


#### 5)
# increase disk size to 100 GB and confirm automatically
gcloud compute disks resize cloudcomputing \
	 --size 100 \
	 --zone=europe-west3-a \
	 <<< y

### get external IP
external_ip=$(gcloud compute instances describe cloudcomputing \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# install sysbench
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa id_rsa@$external_ip "sudo apt update && sudo apt install -y sysbench"

### deploy bench.sh 
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa $PWD/bench.sh id_rsa@$external_ip:

# crontab command
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa id_rsa@$external_ip "(crontab -l 2>/dev/null; echo \"*/30 * * * * ~/bench.sh >> ~/gcp_results.csv\") | crontab -"



