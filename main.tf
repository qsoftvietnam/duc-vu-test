provider "aws" {
	region	= "ap-southeast-1"
}  

provider "google" {
	project = "sh-sandbox"
	region = "us-central1"
}

resource "aws_instance" "web-server" {
	ami	= "ami-08be951cec06726be"
	instance_type = "t2.micro"
	tags = {
	 Name = "web-server"
	}
	user_data = <<-EOF
	 #!/bin/bash
	 apt install nginx
	 systemctl restart nginx
	 sudo apt update
	 sudo apt install apt-transport-https ca-certificates curl software-properties-common
	 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	 sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	 sudo apt update
	 apt-cache policy docker-ce
	 sudo apt install docker-ce
	 sudo docker pull tuhao910/python:app
	 sudo docker run app
	 EOF
}

resource "google_compute_network" "vpc_network" {

  name = "vpc-dev-id-02"

}

resource "google_compute_subnetwork" "subnetwork" {

  name = "subnet-dev-id-02"

}

resource "google_container_cluster" "primary" {
  name     = var.k8s_id
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "vpc-dev-id-02"
  subnetwork = "subnet-dev-id-02"
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "e2-medium"
    tags         = ["gke-node", "${var.project_id}-k8s"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

