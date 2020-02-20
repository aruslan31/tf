provider "aws"{
        access_key = "ACCESSKEY"
        secret_key= "SECRETKEY"
        region = "eu-central-1"
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
default = true
}

resource "aws_alb" "my-alb" {
        name = "my-alb"
        subnets = data.aws_subnet_ids.default.ids
        security_groups = [aws_security_group.my_allow_all.id]
}

resource "aws_alb_target_group" "frontend-target-group" {
        name = "alb-target-group"
        port = 80
        protocol = "HTTP"
        vpc_id = data.aws_vpc.default.id
}


resource "aws_alb_target_group_attachment" "frontend-attachment-1" {
        target_group_arn = "${aws_alb_target_group.frontend-target-group.arn}"
        target_id = "${aws_instance.my_srv_1[0].id}"
        port = "80"
}


resource "aws_alb_target_group" "varnish-target-group" {
        name = "alb-target-group-2"
        port = 80
        protocol = "HTTP"
        vpc_id = data.aws_vpc.default.id
}


resource "aws_alb_target_group_attachment" "varnish-attachment-1" {
        target_group_arn = "${aws_alb_target_group.varnish-target-group.arn}"
        target_id = "${aws_instance.my_srv_2[0].id}"
        port = "80"
}

resource "aws_alb_listener" "frontend-listeners" {
        load_balancer_arn = aws_alb.my-alb.arn
        port = "443"
        protocol = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-2016-08"
        certificate_arn  = "arn:aws:acm:eu-central-1:470279830269:certificate/6a4bfb0e-60af-49df-a2a0-bbd72c33200b"

        default_action {
                #target_group_arn = "${aws_alb_target_group.frontend-target-group.arn}"
                target_group_arn = "${aws_alb_target_group.varnish-target-group.arn}"
                type = "forward"

        }

}

resource "aws_alb_listener_rule" "alb-media-rule" {
        listener_arn = aws_alb_listener.frontend-listeners.arn
        priority = 90

        action {
                type = "forward"
                target_group_arn = aws_alb_target_group.frontend-target-group.arn
        }

        condition {
                path_pattern {
                        values = ["/media/*"]
                }
        }
}

resource "aws_alb_listener_rule" "alb-static-rule" {
        listener_arn = aws_alb_listener.frontend-listeners.arn
        priority = 100

        action {
                type = "forward"
                target_group_arn = aws_alb_target_group.frontend-target-group.arn
        }

        condition {
                path_pattern {
                        values = ["/static/*"]
                }
        }
}



resource "aws_instance" "my_srv_1" {
        count=1
        ami = "ami-0b418580298265d5c"
        instance_type = "t3.micro"
        key_name = "rus-key"
        vpc_security_group_ids = [aws_security_group.my_allow_all.id]
        user_data = file("mage.sh")
}

resource "aws_instance" "my_srv_2" {
        count=1
        ami = "ami-0b418580298265d5c"
        instance_type = "t3.micro"
        key_name = "rus-key"
        vpc_security_group_ids = [aws_security_group.my_allow_all.id]
        user_data = file("vrn.sh")
}


resource "aws_key_pair" "rus-key"  {
  key_name   = "rus-key"
  public_key = "ssh-rsa MYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEYMYRSAKEY ubuntu"
}

resource "aws_security_group" "my_allow_all" {
        name = "Allow all "
        description = "My Allow all Security Group"

        ingress {
                from_port=0
                to_port=0
                protocol="-1"
                cidr_blocks=["0.0.0.0/0"]
        }

        egress {
                from_port=0
                to_port=0
                protocol="-1"
                cidr_blocks=["0.0.0.0/0"]
        }
}

