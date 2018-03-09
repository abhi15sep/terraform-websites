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

# Create a public subnet to launch our bastion into
resource "aws_subnet" "public_b" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "eu-west-2b"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false

  tags {
        Name = "Public Subnet B"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "eu-west-2a"
  cidr_block              = "10.0.130.0/24"
  map_public_ip_on_launch = false

  tags {
        Name = "Private Subnet A"
  }
}

# Create a public subnet to launch our bastion into
resource "aws_subnet" "private_b" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "eu-west-2b"
  cidr_block              = "10.0.140.0/24"
  map_public_ip_on_launch = false

  tags {
        Name = "Private Subnet B"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}"]

  tags {
    Name = "My Private DB subnet group"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_a.id}"

  tags {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "terraform private"
  }
}

resource "aws_route" "private" {
  route_table_id            = "${aws_route_table.private.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.ngw.id}"
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "priv_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private.id}"
}


resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH traffic ONLY"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow Web traffic ONLY"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "lb_sg"
  }
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow HTTP & SSH traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  tags {
    Name = "web"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow MySQL traffic ONLY"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "lb_sg"
  }
}

data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
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

resource "aws_eip" "nat" {
  vpc         = true
}


resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.bastion.id}"
  instance_type = "t2.micro"
  key_name = "bobby-key"
  vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}", "sg-040f213940253fefc"]
  subnet_id = "${aws_subnet.public_a.id}"

  tags {
    Name = "Bastion"
  }
}

resource "template_file" "disk_userdata" {
    template = "${file("scripts/mount.sh")}"
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.packer.id}"
  instance_type = "t2.small"
  key_name = "bobby-key"
  vpc_security_group_ids = ["${aws_security_group.web.id}", "sg-040f213940253fefc"]
  subnet_id = "${aws_subnet.private_a.id}"
  user_data     = "${template_file.disk_userdata.rendered}"

  tags {
    Name = "Web"
  }
}



resource "aws_eip" "bastionip" {
  vpc         = true
  depends_on  = ["aws_internet_gateway.default"]
}

resource "aws_eip_association" "eip_bastion_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastionip.id}"
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



# Create a new load balancer
resource "aws_lb" "web" {
  name            = "test-lb-tf"
  internal        = false
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${aws_subnet.public_a.id}","${aws_subnet.public_b.id}"]

  tags {
    Name = "lb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = "${aws_lb_target_group.web.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "web_ssl" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-2:696293867939:certificate/cb624390-416f-4d14-821d-1646932241a3"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_db_instance" "default" {
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  username             = "bobbyjason"
  vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
  password             = "Bcr-wHs-DFm-8nu"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  parameter_group_name = "default.mysql5.6"
  snapshot_identifier  = "bobbyjason"
  skip_final_snapshot  = true
  final_snapshot_identifier = "deletemeplz"
}