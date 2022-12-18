locals {
  account_id = data.aws_caller_identity.current.account_id
  iam_role   = join(":", ["arn:aws:iam:", local.account_id, "role/LabRole"])
}

variable "MASTODON_ACCESS_TOKEN" {
  description = "Access Token for Mastodon"
  type        = string
  sensitive   = true
}

variable "STABILITY_HOST" {
  description = "stability AI Host"
  type        = string
  sensitive   = true
}

variable "STABILITY_KEY" {
  description = "stability AI key"
  type        = string
  sensitive   = true
}
