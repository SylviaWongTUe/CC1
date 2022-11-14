#!/bin/bash

# ami for image
ami=ami-0f7f61182896079c9


#### 1)
# ensure to have default vpc network
if ! aws ec2 wait vpc-exists; then

    echo "Default VPC network does not exist... creating one"

    aws ec2 create-default-vpc
fi


#### 2)
# generate SSH key pair if necessary
ssh-keygen -q -t rsa -C "id_rsa" -f id_rsa -N "" <<< n

# check if key-pair with key-name "my-key" already exists and delete if necessary
if aws ec2 wait key-pair-exists --key-name my-key; then

    echo "Key-pair with key-name already exists... deleting existing one"

    aws ec2 delete-key-pair --key-name my-key
fi

# import key-pair
aws ec2 import-key-pair --key-name "my-key" --public-key-material fileb://$PWD/id_rsa.pub


#### 3)
# create security group
if ! aws ec2 create-security-group --group-name MySecurityGroup --description "My security group"; then

	echo "Security group with same name already exists... deleting existing one"
    
    # get group id of existing security group
	group_id=$(aws ec2 describe-security-groups --group-names MySecurityGroup --query 'SecurityGroups[*].[GroupId]' --output text)

	# delete it
	aws ec2 delete-security-group --group-id $group_id

	# create new one, store group_id
	group_id=$(aws ec2 create-security-group --group-name MySecurityGroup --description "My security group" --output text)
fi	 

# get IP address
my_ip=$(curl https://checkip.amazonaws.com)

# enable ICMP traffic
aws ec2 authorize-security-group-ingress \
    --group-id $group_id \
    --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'

# enable SSH traffic
aws ec2 authorize-security-group-ingress \
    --group-id $group_id \
    --protocol tcp \
    --port 22 \
    --cidr $my_ip/24


#### 4)
# run instance and store id
instance_id=$(aws ec2 run-instances \
    --image-id $ami \
    --instance-type t2.micro \
    --security-group-ids $group_id \
    --key-name my-key \
    | grep -oP '(?<="InstanceId": ")[^"]*')


#### 5)
# get volume id
volume_id=$(aws ec2 describe-volumes \
    --filters Name=attachment.instance-id,Values=$instance_id \
    | grep -m 1 -oP '(?<="VolumeId": ")[^"]*')


sleep 10


aws ec2 modify-volume --size 30 --volume-id $volume_id

public_dns=$(aws ec2 describe-instances \
    | grep -m 1 -oP '(?<="PublicDnsName": ")[^"]*')

# install sysbench
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa ubuntu@$public_dns "sudo apt update && sudo apt install -y sysbench"

### deploy bench.sh 
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa $PWD/bench.sh ubuntu@$public_dns:

# crontab command
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $PWD/id_rsa ubuntu@$public_dns "(crontab -l 2>/dev/null; echo \"*/30 * * * * ~/bench.sh >> ~/aws_results.csv\") | crontab -"




