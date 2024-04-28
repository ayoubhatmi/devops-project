# On détermine la version du provider OpenStack à utiliser
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"    
      }
      ovh = {
        source = "ovh/ovh"
    }
  }
  required_version = ">= 1.0.0"
}

# On demande à Terraform d'utiliser le provider téléchargé à l'instant
provider "openstack" {
  cloud = "tp1_devops_app"
}

provider "ovh" {
  endpoint = "ovh-eu"
  application_key    = "1598a9a15fae7f32"
  application_secret = "fb1f1c3e068d5cbe2ddd5b71f7fcb84a"
  consumer_key       = "7aad6987a4b6f72191ba25b93a367dbe"
}

