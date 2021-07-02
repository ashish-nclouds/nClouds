locals {
    identifier        = "datadog-scout-2021-tf"
    region            = "us-east-1"
    # Inline policy Datadog scout instance
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}