# #!/bin/bash

# make sure we have default vpc
aws ec2 create-default-vpc

# upload key-pair
aws ec2 import-key-pair \
    --key-name "my-key" \
    --public-key-material fileb://~/.ssh/id_rsa.pub

# create security group and get the security group id
sg_id=$(aws ec2 create-security-group \
    --group-name MySecurityGroup \
    --description "My security group" \
    --output text --query 'GroupId'
    )

# modify policies of security group
    # allow ssh
aws ec2 authorize-security-group-ingress \
    --group-name MySecurityGroup \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --output text \
    --query 'Return'

    #allow IMCP
aws ec2 authorize-security-group-ingress  \
    --group-name MySecurityGroup \
    --protocol 1 \
    --port 1 \
    --cidr 0.0.0.0/0 \
    --output text \
    --query 'Return'

#launch intance
ins_id=$(aws ec2 run-instances \
    --image-id ami-02d63d6d135e3f0f0 \
    --count 1 \
    --instance-type t2.micro \
    --key-name my-key \
    --security-group-ids $sg_id \
    --output text \
    --query 'Instances[0].InstanceId')

#get instance state
ins_state=$(aws ec2 describe-instance-status \
    --instance-ids $ins_id \
    --query 'InstanceStatuses[0].InstanceState.Code')

#get check instance state == running then we can resize the volume
while [ $ins_state != "16" ]
do
    sleep 5

    ins_state=$(aws ec2 describe-instance-status \
        --instance-ids $ins_id \
        --query 'InstanceStatuses[0].InstanceState.Code')

done

#resize the volume
volume_id=$(aws ec2 describe-volumes \
    --filters Name=attachment.instance-id,Values=$ins_id \
    --output text \
    --query 'Volumes[0].VolumeId')

aws ec2 modify-volume \
--size 100 \
--volume-id $volume_id

echo "Done"