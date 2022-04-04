module "labels" {
  source  = "app.terraform.io/igorbrites/labels/common"
  version = "2.0.8"

  project     = "thisCrazyName"
  customer    = "MrMaggoo"
  application = "thisCrazyApp"
  stage       = "production"
}
