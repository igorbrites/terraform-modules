# Labels

The docs on how to use the module is [here](https://app.terraform.io/app/igorbrites/registry/modules/private/igorbrites/labels/common).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Type of application, e.g. `"backend"`, `"frontend"` or `"keycloak"` | `string` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | Customer name | `string` | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `name`, `namespace`, `stage`, etc. | `string` | `"-"` | no |
| <a name="input_project"></a> [project](#input\_project) | Solution name, e.g. `"app"` or `"jenkins"` | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Environment stage, e.g. `"dev"`, `"staging"` or `"production"` | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{BusinessUnit = "XYZ"}` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\_application) | Normalized application |
| <a name="output_customer"></a> [customer](#output\_customer) | Normalized customer |
| <a name="output_id"></a> [id](#output\_id) | Normalized id, it is a concat of: customer, application, name, and stage |
| <a name="output_project"></a> [project](#output\_project) | Normalized project name |
| <a name="output_stage"></a> [stage](#output\_stage) | Normalized stage |
| <a name="output_tags"></a> [tags](#output\_tags) | Normalized Tag map |
<!-- END_TF_DOCS -->
