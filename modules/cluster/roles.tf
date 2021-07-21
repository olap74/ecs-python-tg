# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-${var.environment}-${var.ecs_task_execution_role_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy" "ecs_task_execution_role" {
  name_prefix = "ecs_iam_role_policy"
  role        = aws_iam_role.ecs_task_execution_role.id
  policy      = data.template_file.ecs_service_policy.rendered
}

data "template_file" "ecs_service_policy" {
  # Allow logs for cloudwatch
  # Allow ecs & ecr access as per
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
  #
  # Allow ec2 describe instances so that the instance can see its own metadata if needed
  #
  # Allow param store access only to the namespace of this cluster
  # You can/should create even more granular param access depending
  # on the additional services you run in this cluster.
  #
  # Please read:
  # https://aws.amazon.com/blogs/mt/the-right-way-to-store-secrets-using-parameter-store/
  # for additional steps you can take to impart least permissions with ECS.
  #
  # Note: Once you have created a KMS key for this ECS service,
  # kms access should be limited to that KMS key.
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe",
        "ec2:DescribeInstances"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
         "kms:ListKeys",
         "kms:ListAliases",
         "kms:Describe*",
         "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.app_name}-${var.environment}-${var.ecs_task_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_role" {
  name = "${var.app_name}-${var.environment}-${var.ecs_task_role_name}"
  role = aws_iam_role.ecs_task_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
