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
