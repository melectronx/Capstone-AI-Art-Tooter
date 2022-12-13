locals {
  account_id = data.aws_caller_identity.current.account_id
  iam_role   = join(":", ["arn:aws:iam:", local.account_id, "role/LabRole"])
  art_bucket = "ai-art-tooter-img"
}
variable "art_bucket" {
  description = "Bucket for ART"
  type        = string
  default     = "ai-art-tooter-img"
}