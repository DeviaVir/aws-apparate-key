#!/bin/bash

bucket={{ release_bucket }}
access_key={{ s3key }}
access_secret={{ s3secret }}
keyname=/root/.ssh/id_rsa

if [ -e $keyname ]; then
    echo "Found existing $keyname, moving it out of the way.";
    mv $keyname $keyname.bak
fi

aws s3 cp --quiet s3://$bucket/sysops.pem $keyname
result=$?

if [ $result -ne 0 ]; then
    echo "Downloading key from s3 failed, generating a new one";

    ssh-keygen -t rsa -b 2048 -f $keyname -N "" -C root@`hostname`
    aws s3 cp $keyname s3://$bucket/sysops.pem
else
    echo "Downloaded key from s3";
    chmod 600 $keyname
    ssh-keygen -y -f $keyname > ${keyname}.pub
fi

