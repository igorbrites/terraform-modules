module "labels_with_additional_tags" {
  source  = "app.terraform.io/igorbrites/labels/common"
  version = "2.0.8"

  project     = "thisCrazyName"
  customer    = "MrMaggoo"
  application = "thisCrazyApp"
  stage       = "dev"
  delimiter   = "."
  tags = {
    BusinessUnit = "XYZ",
    Snapshot     = "true",
  }
}
