provider "aws" {
  region     = "eu-west-2"
}

resource "aws_key_pair" "bobby" {
  key_name   = "bobby-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTaCOFI3z2bs5fRF3bHZpT03cmH/6wbZgjO5NKqb8xHRXYx6HiQWiP2GVV+F281MHC/ZJ5RaU1ex+uSm6ZCymMu9sHVhqViqeNHpHQadPRGApJKS5JDbpvQKxx/FH2kC7yV8mUfdsYHbMFQnJVtfef7LuZqJtvyOMzs/pXUfpq3rhgtcWkAtiu1C9QB/S7OoZztjjiVKx4SUZUTQxiw4PKTWvsdZ5Ctdd1IUgtseXoHYCf4NI5BBcA4sFNBJAAmatdlD7id+4kSSkTlIlBUudWidMoQzEczk+tFGHSd3Mp2dc205SlbmJhktWeOUCxdqmwzFljlV3L8ZvGllkVBXyR me@bobbyjason.co.uk"
}

resource "aws_key_pair" "steve" {
  key_name   = "steve-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDejblH1bRTFpJE/837Vqs/OtPov55jzpb7DPKBTDLD85Fffy2NBKOJ+bFigOvxxjxHcdFOjduYKs6N3B7JkfIp7+j692NzzpZoNCxgvLLlG9g+I/ISdxDWChADe/CdEvpzIM85y4JWOJ8xdDoYs2tm+HA7ey5NRkgWPknDzHNmOCOe+47/V8Tmm+KIrjgtWRqPHDq8W8kYpeRcLYPqRsv1xduvBFUEbDxzGZSXtWNR9KxUNjV91ULFaHaNeQrahRkhcFhq2LWc4mC/+EGK+EoPqPLphDw2t0PiK/yVBPjaeVMXEs6RP9T+PNvLIu0nl/eJFB8ZXv/ZND36f/42J+wh Steve@Steve-THINK"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "Main VPC"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a public subnet to launch our bastion into
resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "eu-west-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags {
        Name = "Public Subnet A"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_security_group" "ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH & HTTP traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh,http"
  }
}

data "aws_ami" "packer" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.packer.id}"
  instance_type = "t2.small"
  key_name = "bobby-key"
  vpc_security_group_ids = ["${aws_security_group.ssh_http.id}"]
  subnet_id = "${aws_subnet.public_a.id}"

  tags {
    Name = "Packer build"
  }
}

data "aws_ebs_volume" "ebs_volume" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "tag:Name"
    values = ["website-data"]
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdh"
  volume_id   = "${data.aws_ebs_volume.ebs_volume.id}"
  instance_id = "${aws_instance.web.id}"
  skip_destroy = true
}

resource "aws_eip" "elasticip" {
  vpc         = true
  depends_on  = ["aws_internet_gateway.default"]
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.web.id}"
  allocation_id = "${aws_eip.elasticip.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo mount /dev/xvdh /srv"
    ]
    
    connection {
      host     = "${self.public_ip}"
      user     = "ec2-user"
      timeout  = "5m"
    }
  }
}
