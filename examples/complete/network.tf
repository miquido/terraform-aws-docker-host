# A minimal network for the example: one public subnet. The host gets an Elastic IP; access is limited by the
# security group of the module (SSH from allowed_cidr, 80/443 from anywhere). Use your own VPC in real setups.
data "aws_availability_zones" "available" {
  state = "available"

  # Exclude local and wavelength zones the account may be opted in to.
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = var.project }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.50.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "${var.project}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# The wrapper creates the A records in an existing zone; the example creates the zone too.
resource "aws_route53_zone" "main" {
  name = var.domain
}
