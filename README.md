# quotes

aws ec2 authorize-security-group-ingress --group-id sg-074e243dbe08df0e0 --protocol tcp --port 22 --cidr 0.0.0.0/24
aws ec2 revoke-security-group-ingress --group-id sg-074e243dbe08df0e0 --protocol tcp --port 22 --cidr 0.0.0.0/24