terraform {
  backend "s3" {
    access_key = "AKIAS66UDFB23RPT6DGG"
  secret_key = "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"
    bucket = "mytestteraform"
    key    = "mystate/key"
    region = "ap-south-1"
  }
}
provider "aws" {
  access_key = "AKIAS66UDFB23RPT6DGG"
  secret_key = "vSMWS60ck3AfdwsIgXS8oF5kEhi85KuihvYKU/Gg"
  region = "ap-south-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04a37924ffe27da53"  # Amazon Linux 2 AMI in ap-south-1 region (update if needed)
  instance_type = "t2.micro"

  tags = {
    Name = "MyT2MicroInstance"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
