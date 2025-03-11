# Overview
> This repository is currently heavily in development

This is a pure terraform based solution for managing a Kubernetes Cluster. It includes the following:
1. A Terraform based deployment for a High-Availability Ceph Data lake using Ansible Provider.
1. A Terraform based deployment for a High-Availability Kubernetes Cluster with an external Ceph Cluster connected as a storage class for Kubernetes native storage. 
1. A Terraform based deployment for a full LMA stack of Prometheus, Grafana and Loki backed by an Object Store (S3 compatible on Ceph). 
1. A Terraform based deployment for a globally accessible S3 object store using Cloudflare Tunnels. 
1. A Terraform based deployment for a Keycloak Instance for IAM Administration
1. A Terraform based deployment for custom OIDC client that can be used across various clients for secure access
1. A Terraform based deployment for Cloudflare self hosted apps
1. A Terraform based deployment for a Personal AI Assitant.

