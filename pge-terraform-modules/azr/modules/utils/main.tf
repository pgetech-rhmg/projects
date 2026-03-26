#
# Filename    : az/modules/utils/main.tf
# Date        : 29 Jan 2026
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : sample azure utils module
#

/*
* # Azure sample module
* Terraform module to output 'hello, azure!'
*/

# outputs
output "message" {
  value = "hello, azure! - PGE CCOE"
}

