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
    region = var.region
}

#IAM Users
resource "aws_iam_user" "weaver" {
    name = "weaver"
    tags = {
        Name = "weaver"
        Quest = "up"
    }
}

resource "aws_iam_user" "starker" {
    name = "starker"
    tags = {
        Name = "starker"
        Quest = "up"
    }
}

#IAM Users' Access keys
resource "aws_iam_access_key" "weaver-keys" {
    user = aws_iam_user.weaver.name
}

resource "aws_iam_access_key" "starker-keys" {
    user = aws_iam_user.starker.name
}

#Defining Data Sources
data "local_file" "v1" {
  filename = "../policies/v1.json"
}

data "local_file" "v2" {
  filename = "../policies/v2.json"
}

data "local_file" "v3" {
  filename = "../policies/v3.json"
}

data "local_file" "v4" {
  filename = "../policies/v4.json"
}

data "local_file" "v5" {
  filename = "../policies/v5.json"
}

#Creating Policies and attaching to user weaver
resource "null_resource" "up-policy-v2" {
    provisioner "local-exec" {
        command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.weaver-policy.arn} --policy-document file://../policies/v2.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
    }
}

resource "null_resource" "up-policy-v4" {
    provisioner "local-exec" {
        command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.weaver-policy.arn} --policy-document file://../policies/v4.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
    }
}

resource "null_resource" "up-policy-v5" {
    provisioner "local-exec" {
        command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.weaver-policy.arn} --policy-document file://../policies/v5.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
    }
}

#IAM Policy for Weaver
resource "aws_iam_policy" "weaver-policy" {
    name = "weaver-policy"
    policy = file("../policies/v1.json")
}

#IAM Policy attachment for weaver
resource "aws_iam_user_policy_attachment" "weaver-policy-attachment" {
    user = aws_iam_user.weaver.name
    policy_arn = aws_iam_policy.weaver-policy.arn
}

#IAM Policy for starker
resource "aws_iam_policy" "starker-policy" {
    name = "starker-policy"
    policy = file("../policies/v3.json")
}

#IAM Policy Attachment for starker
resource "aws_iam_user_policy_attachment" "starker-policy-attachment" {
    user = aws_iam_user.starker.name
    policy_arn = aws_iam_policy.starker-policy.arn
}

#Outputs
output "user_1" {
    value = aws_iam_user.weaver.name
}

output "weaver_access_key_id" {
    value = aws_iam_access_key.weaver-keys.id
}

output "weaver_secret_key" {
    value = aws_iam_access_key.weaver-keys.secret
} 

output "user_2" {
    value = aws_iam_user.starker.name
}

output "starker_access_key_id" {
    value = aws_iam_access_key.starker-keys.id
}

output "starker_secret_key" {
    value = aws_iam_access_key.starker-keys.secret
} 