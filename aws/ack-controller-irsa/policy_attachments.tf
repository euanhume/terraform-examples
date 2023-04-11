resource "aws_iam_role_policy_attachment" "iam_role_policy_attachments" {
  for_each = var.ack_policies

  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.iam_roles[each.key].name
}