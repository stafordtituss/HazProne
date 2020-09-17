#Variables
variable "profile" {

}

variable "region" {
    default = "us-east-1"
}

variable "userIP" {
    
}

#Provider
provider "aws" {
    profile = var.profile
    region = "us-east-1"
}

#AWS Key-Pair
resource "aws_key_pair" "example" {
    key_name = "exkey"
    public_key = file("./terraform.pub")
}

#VPC
resource "aws_vpc" "vpc-server" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
}

#Internet-Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc-server.id}"
}

#Subnet
resource "aws_subnet" "public-subnet" {
  availability_zone = "${var.region}a"
  cidr_block = "10.10.10.0/24"
  vpc_id = "${aws_vpc.vpc-server.id}"
}

#Subnet-Routing-Table
resource "aws_route_table" "subnet-route-table" {
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.internet-gateway.id}"
  }
  vpc_id = "${aws_vpc.vpc-server.id}"
}

#Route Table Association
resource "aws_route_table_association" "route-association" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.subnet-route-table.id}"
}

#Security Group
resource "aws_security_group" "security-group" {
  name = "security-group"
  vpc_id = "${aws_vpc.vpc-server.id}"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.userIP}"]
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }
}

#IAM User
resource "aws_iam_user" "pablo" {
    name = "pablo"
}

#IAM User Acces Keys
resource "aws_iam_access_key" "pablo-keys" {
    user = aws_iam_user.pablo.name
}

#IAM User policy
resource "aws_iam_user_policy" "pablo-policy" {
  name = "pablo-policy"
  user = aws_iam_user.pablo.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "iam:ListUsers",
                "s3:ListAllMyBuckets",
                "dynamodb:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#DynamoDB Policy
resource "aws_dynamodb_table" "final-secret-dynamo" {
    name = "final-secret-dynamo"
    read_capacity = 5
    write_capacity = 5
    hash_key = "key"
    attribute {
        name = "key"
        type = "S"
    }
}

#DynamoDB Table
resource "aws_dynamodb_table_item" "finals-flag" {
    table_name = aws_dynamodb_table.final-secret-dynamo.name
    hash_key = aws_dynamodb_table.final-secret-dynamo.hash_key
    item = <<EOF
    {
        "key": {"S": "flag"},
        "value": {"S": "HazProne{7h!5_!5_N07_7H3_3nD}"}
    }
    EOF
}

#IAM Role
resource "aws_iam_role" "access-ddb" {
    name = "access-ddb"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
        }
    ]
}
EOF
}

#IAM Policy
resource "aws_iam_policy" "access-ddb-policy" {
    name = "access-ddb-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": [
            "dynamodb:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
    }
    ]
}
EOF
}

#Role Policy Attachment
resource "aws_iam_role_policy_attachment" "access-ddb-rp-attachment" {
    role = aws_iam_role.access-ddb.name
    policy_arn = aws_iam_policy.access-ddb-policy.arn
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "access-ddb-instance-prof" {
    name = "access-ddb-instance-prof"
    role = aws_iam_role.access-ddb.name
}

#EC2 Instance
resource "aws_instance" "finals-server" {
    key_name = aws_key_pair.example.key_name
    ami = "ami-2757f631"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.access-ddb-instance-prof.name
    subnet_id = "${aws_subnet.public-subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.security-group.id}"]
    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        sudo adduser creaden
        echo "creaden:BlastOffToMars" |sudo chpasswd
        sudo echo "creaden ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
        sudo sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config
        sudo service sshd restart 

        sudo apt-get install -y apache2
        sudo chmod 777 /var/www/html/
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
        sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'secret';"
        echo -e "[mysql] \nuser = root \npassword=secret" >> ~/.my.cnf
        echo -e "[mysql] \nuser = root \npassword=secret" >> /home/creaden/.my.cnf
        sleep 15s
        sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS hazprone; USE hazprone; CREATE TABLE IF NOT EXISTS pablokeys(accesskeyid VARCHAR(50), secretkey VARCHAR(50)); INSERT INTO pablokeys VALUES ('${aws_iam_access_key.pablo-keys.id}', '${aws_iam_access_key.pablo-keys.secret}');"
        sudo rm /var/www/html/index.html
        sudo apt-get install -y php libapache2-mod-php php-mcrypt
        sudo echo ${base64encode(file("../stuff/readme.txt"))} | base64 --decode > /home/ubuntu/readme.txt
        sudo echo ${base64encode(file("./terraform"))} | base64 --decode > /home/ubuntu/key.pem
        sudo echo ${base64encode(file("../webapp/index.php"))} | base64 --decode > /var/www/html/index.php
        sudo echo ${base64encode(file("../webapp/ping.php"))} | base64 --decode > /var/www/html/ping.php
        sudo systemctl restart apache2
        EOF

    root_block_device {
        delete_on_termination = true
    }

}

#Output
output "public-ip" {
    value = "${aws_instance.finals-server.public_ip}/index.php"
}