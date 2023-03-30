resource kubernetes_storage_class_v1 ebs_csi_gp3 {
  metadata {
    name = "ebs-csi-gp3"
    labels = {
      "app.kubernetes.io/component" = "csi-driver"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/name" = "ebs-csi-gp3"
      "app.kubernetes.io/part-of" = "aws-ebs-csi-driver"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
    encrypted = "true"
    kmsKeyId = aws_kms_key.cmk_volumes.arn
  }
}

resource kubernetes_storage_class_v1 ebs_csi_gp3_premium {
  metadata {
    name = "ebs-csi-gp3-premium"
    labels = {
      "app.kubernetes.io/component" = "csi-driver"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/name" = "ebs-csi-gp3-premium"
      "app.kubernetes.io/part-of" = "aws-ebs-csi-driver"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
    allowAutoIOPSPerGBIncrease = "true"
    iops = "8000"
    encrypted = "true"
    kmsKeyId = aws_kms_key.cmk_volumes.arn
  }
}

resource kubernetes_storage_class_v1 ebs_csi_gp2 {
  metadata {
    name = "ebs-csi-gp2"
    labels = {
      "app.kubernetes.io/component" = "csi-driver"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/name" = "ebs-csi-gp2"
      "app.kubernetes.io/part-of" = "aws-ebs-csi-driver"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp2"
    encrypted = "true"
    kmsKeyId = aws_kms_key.cmk_volumes.arn
  }
}