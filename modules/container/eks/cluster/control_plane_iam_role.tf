resource aws_iam_role control_plane {
  name = "role-${local.eks_cluster_name}-control-plane"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge({
    Name = "role-${local.eks_cluster_name}-control-plane"
  }, local.module_common_tags)
}

resource aws_iam_role_policy_attachment eks_cluster_policy {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.control_plane.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource aws_iam_role_policy_attachment eks_vpc_resource_controller {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.control_plane.name
}

# allow cluster to put metric data to CloudWatch
resource aws_iam_role_policy cloud_watch_metrics {
  role = aws_iam_role.control_plane.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}

# allow cluster to retrieve EC2 data related to loadbalancers
resource aws_iam_role_policy elb_permissions {
  role = aws_iam_role.control_plane.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInternetGateways"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}
