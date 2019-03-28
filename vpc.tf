/* AWS VPC */
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform_aws_vpc"
  }
}

/* Internet Gateway */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "terraform_aws_ig"
  }
}

/* Private Subnet */
resource "aws_subnet" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Private Subnet"
  }
}

/* Public Subnet */
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Public Subnet"
  }
}

/* Bastion Node Security Group */
resource "aws_security_group" "bastion" {
  name        = "bastion_sg"
  vpc_id      = "${aws_vpc.default.id}"
  description = "Security group Bastion Node"

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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bastion-sg"
  }
}

/* Nodes Security Group */
resource "aws_security_group" "node" {
  name        = "minion_sg"
  vpc_id      = "${aws_vpc.default.id}"
  description = "Security group Minions"

  tags {
    Name = "minion-sg"
  }
}

/* Bastion Node Security Group */
resource "aws_route_table" "aws_rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Route Table"
  }
}

resource "aws_route_table_association" "aws_rta" {
  subnet_id      = "${aws_subnet.eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.aws_rt.id}"
}


/* Bastion Node Launch Configuration*/
resource "aws_launch_configuration" "bastion" {
  name = "bastion"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  image_id = "${lookup(var.ami,var.aws_region)}"
  security_groups = ["${aws_security_group.bastion.id}"]
  key_name = "${var.aws_key_name}"
  lifecycle {
    create_before_destroy = true
  } 
}

/* Bastion Node Autoscalling Group */
resource "aws_autoscaling_group" "bastion_asg" {
  name = "bastion_asg"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a-public.id}"]
}

/* Nodes Launch Configuration */
resource "aws_launch_configuration" "nodes" {
  name = "nodes"
  associate_public_ip_address = false
  instance_type = "t2.micro"
  image_id = "${lookup(var.ami, var.aws_region)}"
  security_groups = ["${aws_security_group.node.id}"]
  key_name = "${var.aws_key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

/* Nodes Autoscalling Group */
resource "aws_autoscaling_group" "nodes_asg" {
  name = "bastion_asg"
  min_size = 2
  max_size = 5
  desired_capacity = 3
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.nodes.name}"
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a-private.id}"]
}

/* Master Node Launch Configuration */
resource "aws_launch_configuration" "master" {
  name = "nodes"
  associate_public_ip_address = false
  instance_type = "t2.micro"
  image_id = "${lookup(var.ami, var.aws_region)}"
  security_groups = ["${aws_security_group.node.id}"]
  key_name = "${var.aws_key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

/* Master Node Autoscalling Group */
resource "aws_autoscaling_group" "master_asg" {
  name = "bastion_asg"
  min_size = 2
  max_size = 5
  desired_capacity = 3
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.master.name}"
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a-private.id}"]
}






