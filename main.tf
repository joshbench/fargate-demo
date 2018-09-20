# Specify the provider and access details
provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "jbench-certs"
}

## ECS

resource "aws_ecs_cluster" "main" {
  name = "terraform_example_ecs_cluster"
}

resource "aws_ecs_task_definition" "upload-to-s3" {
  family                   = "upload-to-s3"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.app_image}",
    "name": "jbench-fargate",
    "networkMode": "awsvpc"
  }
]
DEFINITION
}

## IAM

resource "aws_iam_role" "ecs_events" {
  name = "ecs_events"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}
resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = "${aws_iam_role.ecs_events.id}"
  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(aws_ecs_task_definition.upload-to-s3.arn, "/:\\d+$/", ":*")}"
        }
    ]
}
DOC
}

## CloudWatch

resource "aws_cloudwatch_event_rule" "run_nightly" {
  name                = "RunNightly"
  description         = "run task nightly"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "run-scheduled-task-nightly"
  arn       = "${aws_ecs_cluster.main.arn}"
  rule      = "${aws_cloudwatch_event_rule.run_nightly.name}"
  role_arn  = "${aws_iam_role.ecs_events.arn}"

  ecs_target = {
    task_count = 1
    task_definition_arn = "${aws_ecs_task_definition.upload-to-s3.arn}"
  }

}