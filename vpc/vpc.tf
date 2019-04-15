/*AWS VPC*/
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
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

/*Route Table Association*/
resource "aws_route_table_association" "aws_rta" {
  subnet_id      = "${aws_subnet.eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.aws_rt.id}"
}
