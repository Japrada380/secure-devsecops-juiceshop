resource "aws_guardduty_detector" "security_baseline" {
  enable = true

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-guardduty"
    }
  )
}