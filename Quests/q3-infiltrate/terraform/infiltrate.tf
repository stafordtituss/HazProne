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

#EC2 Instance : Secret-Server
resource "aws_instance" "secret-server" {
    key_name = aws_key_pair.example.key_name
    ami = "ami-2757f631"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    associate_public_ip_address = false
    subnet_id = aws_subnet.subnet-server.id
    vpc_security_group_ids = [aws_security_group.security-group.id]
    private_ip = "192.168.0.112"
    user_data = <<-EOF
        #!/bin/bash
        echo "The Flag is: HazProne{W3_H@v3_b33N_C0mPr0m1s3D}" >> /home/ubuntu/imp.txt
        echo "The answer for Exercise 2 is SGF6UHJvbmV7VGghNV8hNV9uMHRfVGgzXzNeRH0=" >> /mnt/secrets.txt
        EOF
    
    root_block_device {
        delete_on_termination = true
    }

}

#EC2 Instance : Public-Server
resource "aws_instance" "public-server" {
    key_name = aws_key_pair.example.key_name
    ami = "ami-2757f631"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = aws_subnet.subnet-server.id
    vpc_security_group_ids = [aws_security_group.security-group.id]
    private_ip = "192.168.0.111"
    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        sudo adduser treblechef
        echo "treblechef:Newbie" |sudo chpasswd
        sudo echo "treblechef ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
        sudo sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config
        sudo service sshd restart 

        sudo apt-get install -y apache2
        sudo chmod 777 /var/www/html/
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
        sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'secret';"
        echo -e "[mysql] \nuser = root \npassword=secret" >> ~/.my.cnf
        echo -e "[mysql] \nuser = root \npassword=secret" >> /home/treblechef/.my.cnf
        sleep 15s
        sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS hazprone; USE hazprone; CREATE TABLE IF NOT EXISTS secrets(username VARCHAR(50), password VARCHAR(50)); INSERT INTO secrets VALUES ('treblechef', 'Newbie');"
        sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS hazprone; USE hazprone; CREATE TABLE IF NOT EXISTS ques_table(QuesID INT AUTO_INCREMENT, question VARCHAR(500), answer VARCHAR(500), PRIMARY KEY (QuesID)); INSERT INTO ques_table(question, answer) VALUES ('How hard to use is Terraform?', 'Terraform is pretty easy to use.'); INSERT INTO ques_table(question, answer) VALUES ('Why is Math so important?', 'Math is the basic symmetrical ideology behind every notion.'); INSERT INTO ques_table(question, answer) VALUES ('What is black and white and read all over?', 'A Newspaper.'); INSERT INTO ques_table(question, answer) VALUES ('Who is God?', 'God is love.');"
        sudo mysql -u root -e "USE hazprone; INSERT INTO ques_table(question, answer) VALUES ('Who is Google's Dad?', 'Right now, it is Sundar Pichai.'); INSERT INTO ques_table(question, answer) VALUES ('Where is Gotham City?', 'Gotham is an imaginary city only present in the DC World.');"

        sudo echo ${base64encode(file("../webapp/index.php"))} | base64 --decode > /var/www/html/index.php
        sudo echo ${base64encode(file("../webapp/questions.php"))} | base64 --decode > /var/www/html/questions.php
        sudo echo ${base64encode(file("../webapp/db_connect.php"))} | base64 --decode > /var/www/html/db_connect.php
        sudo echo ${base64encode(file("../webapp/search_all_ques.php"))} | base64 --decode > /var/www/html/search_all_ques.php
        sudo echo ${base64encode(file("../webapp/search_keyword.php"))} | base64 --decode > /var/www/html/search_keyword.php
        sudo echo ${base64encode(file("../webapp/robots.txt"))} | base64 --decode > /var/www/html/robots.txt

        sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql
        sudo systemctl restart apache2

        sudo echo ${base64encode(file("./terraform"))} | base64 --decode > /home/treblechef/key.pem
        sudo chmod 400 /home/treblechef/key.pem
        EOF

    root_block_device {
        delete_on_termination = true
    }

}

#VPC
resource "aws_vpc" "vpc-server" {
    cidr_block = "192.168.0.0/24"
    enable_dns_hostnames = false
    enable_dns_support = true
    instance_tenancy = "default"
}

#Internet gateway
resource "aws_internet_gateway" "internet-gateway" {
    vpc_id = aws_vpc.vpc-server.id
}

#Subnet
resource "aws_subnet" "subnet-server" {
    vpc_id =aws_vpc.vpc-server.id
    cidr_block = "192.168.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
}

#Security Group
resource "aws_security_group" "security-group" {
    name = "Cloud-Security-Group"
    description = "Allow only my IP"
    vpc_id = aws_vpc.vpc-server.id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.userIP}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups =[]
        self = true
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Route Table
resource "aws_route_table" "route-table" {
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }
    vpc_id = aws_vpc.vpc-server.id
}

#Route Table Association
resource "aws_route_table_association" "route-table-association" {
    subnet_id = aws_subnet.subnet-server.id
    route_table_id = aws_route_table.route-table.id
}

#Network Access Control List
resource "aws_network_acl" "network-acl" {
  vpc_id     = aws_vpc.vpc-server.id
  subnet_ids = [aws_subnet.subnet-server.id]

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

}

#Outputs
output "ip" {
    value = aws_instance.public-server.public_ip
}

output "website" {
    value = "${aws_instance.public-server.public_ip}/index.php"
}