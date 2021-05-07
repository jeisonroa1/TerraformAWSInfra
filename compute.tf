
###############################

resource "aws_launch_configuration" "lc_front" { #############agent-lc
    #name = "front-"
    vpc_classic_link_id = aws_vpc.main.id
    name_prefix = "front-"
    image_id = var.ami  
    instance_type = var.instance_type
    user_data = file("init-front-instance.sh")

    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "10"
    }
}

resource "aws_autoscaling_group" "asg_front" {
    availability_zones = var.azs
    name = "front"
    max_size = "3"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "EC2"
    desired_capacity = 2
    force_delete = true
    load_balancers = [ aws_lb.lb_front.id  ]
    launch_configuration = aws_launch_configuration.lc_front.name
}