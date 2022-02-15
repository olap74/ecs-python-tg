data "aws_ami" "bastion" {
  most_recent = true
  owners = ["amazon"] # AWS

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "bastion" {
    key_name   = format("%s-bastion-key", var.environment)
    public_key = var.ssh_public_key
}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.bastion.id  
    instance_type = "t2.micro" 
    key_name= aws_key_pair.bastion.key_name
    vpc_security_group_ids = [aws_security_group.bastion_ssh.id]
    associate_public_ip_address = true
    subnet_id     = aws_subnet.public[0].id
    
    tags = {
        Name = format("%s-%s-bastion", var.app_name, var.environment)
    }
    lifecycle {
        create_before_destroy = true
    }  
}

resource "aws_security_group" "bastion_ssh" {
  name        = format("%s-bastion", var.environment)
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH Public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
