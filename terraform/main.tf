module "network" {
    source = "github.com/terraform-yc-modules/terraform-yc-vpc" 

    network_name = "momo-store-cluster-network"
    create_sg    = false
    #create_vpc          = true
    public_subnets = [
        {
        "v4_cidr_blocks" : ["10.121.0.0/16"],
        "zone" : "ru-central1-a"
        },
        {
        "v4_cidr_blocks" : ["10.131.0.0/16"],
        "zone" : "ru-central1-b"
        },
        {
        "v4_cidr_blocks" : ["10.141.0.0/16"],
        "zone" : "ru-central1-d"
        },
    ]
}
module "kubernetes" {
    source = "github.com/terraform-yc-modules/terraform-yc-kubernetes"

    network_id = module.network.vpc_id
    master_locations = [
      {
        zone      = module.network.public_subnets["10.121.0.0/16"].zone,
        subnet_id = module.network.public_subnets["10.121.0.0/16"].subnet_id
      },
      {
        zone      = module.network.public_subnets["10.131.0.0/16"].zone,
        subnet_id = module.network.public_subnets["10.131.0.0/16"].subnet_id
      },
      {
        zone      = module.network.public_subnets["10.141.0.0/16"].zone,
        subnet_id = module.network.public_subnets["10.141.0.0/16"].subnet_id
      },
    ]

    node_groups = {
      "momo-store-node" = {

        auto_scale = {
            min = 1
            initial = 1 
            max = 3
        }
        metadata = {
            "enable-oslogin" = "true"
        }
        labels = {
            owner = "momo-store-cluster"
            service = "kubernetes"
        }
        node_cores = 2
        node_memory = 4
        nat = true
        preemptible  = true

        
      }
    }
}