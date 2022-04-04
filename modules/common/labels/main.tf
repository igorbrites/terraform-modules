locals {
  id          = lower(join(var.delimiter, compact(concat(tolist([var.customer, var.project, var.application, var.stage])))))
  project     = lower(format("%v", var.project))
  customer    = lower(format("%v", var.customer))
  application = lower(format("%v", var.application))
  stage       = lower(format("%v", var.stage))

  tags = merge({
    "Name"        = local.id,
    "Customer"    = local.customer,
    "Application" = local.application,
    "Stage"       = local.stage,
    "Created by"  = "Terraform"
  }, var.tags)
}
