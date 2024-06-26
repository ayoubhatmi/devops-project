data "openstack_images_image_v2" "image" {
    name = "Official-debian-11"
    tags = ["latest"]
}

resource "openstack_compute_instance_v2" "my-instance" {
    name            = "instance-1"
    image_id        = data.openstack_images_image_v2.image.id
    flavor_name     = "v1.m1.d10"
    security_groups = ["default"]
    user_data       = file("./conf.yml")
    network {
        name = openstack_networking_network_v2.network.name
    }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
    pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
    floating_ip = openstack_networking_floatingip_v2.fip_1.address
    instance_id = openstack_compute_instance_v2.my-instance.id
}

resource "openstack_blockstorage_volume_v2" "database_volume" {
    name = "database-volume"
    size = 1 
}

resource "openstack_compute_volume_attach_v2" "attach_volume" {
    instance_id = openstack_compute_instance_v2.my-instance.id
    volume_id   = openstack_blockstorage_volume_v2.database_volume.id
    device      = "/dev/vdb" 
}

 resource "ovh_domain_zone_record" "projet" {
  zone = "uca-devops.ovh"
  subdomain = "projet.ayoub"
  target = "185.34.141.134"
  fieldtype = "A"
}

resource "ovh_domain_zone_record" "blog" {
  zone = "uca-devops.ovh"
  subdomain = "blog.ayoub"
  target = "185.34.141.134"
  fieldtype = "A"
}

resource "ovh_domain_zone_record" "cloud" {
  zone = "uca-devops.ovh"
  subdomain = "cloud.ayoub"
  target = "185.34.141.134"
  fieldtype = "A"
}