# GitOps AWS EKS Deployment Project

In this project I deploy a containerised app using Docker onto AWS EKS with Infrastructure as Code using Terraform, and automate developer changes using GitHub Actions as my CI/CD. I also use helm charts such as NGINX Ingress Controller, External (Dynamic) DNS for automating DNS records, Cert Manager for automated TLS, ArgoCD for GitOps methodoloy, and Prometheus and Graphana for monitoring and observability.

## Project Overview

This project entails a production ready Kubernetes deployment on AWS EKS with managed infrastructure as code using Terraform and helm charts deployed with Helmfile. The app is a 2048 game which I have dockerised and pushed to AWS ECR, the pods pull this image.

The terraform infrastructure overview:

- Bootstrap folder to manage and spin up ECR for the docker image, S3 bucket for storing the terraform state in a remote backen, and DynamoDB for state locking
- Custom VPC with 3 Availability zones, a public and private subnet in each AZ. Regional NAT gateway, route tables, internet gateway, and VPC flow logs
- EKS cluster with 3 worker nodes, relevant addons and IAM roles
- Pod identity configuration for specific pods to access external AWS resources
- Security groups for node to node traffic on TCP/UDP, cluster to node traffic, and cluster to kubelet traffic
- Modular Terraform code design for reusability and ease of maintenance

The helm charts used were:

- NGINX Ingress Controller: choice of Ingress controller for external traffic coming into the cluster
- External DNS to manage Route 53 records dynamically
- Cert Manager for dynamic and automated TLS certificates
- ArgoCD for a GitOps architecture
- Prometheus and Graphana: observability and monitoring tools, prometheus to scrape metrics and data from the cluster, and graphana to create dashboards based on the prometheus metrics

<!-- Application containerised using Docker to run consistently in all environments.

Bootstrap Terraform folder to boot up and manage ECR repo, S3 bucket for remote backend, and DynamoDB for state locking

VPC with 3 Availability zones in region eu-west-2, public and private subnets, route tables, regioinal NAT gateway, VPC flow logs.

EKS cluster security groups for:

- Nodes accepting traffic from cluster SG
- kubelet accepting traffic from cluster SG (on port 10250)
- node to node traffic TCP/UDP

NGINX Ingress Controller as choice of Ingress Controller

External DNS for dynamic DNS records for App, Argocd, Prometheus, Graphana.

Cert Manager for automated TLS encryption.

ArgoCD for GitOps driven architecture.

Prometheus and Graphana for monitoring and observability.

Pod Identities for Node to AWS services communication -->

## Deployed app

<img src="./readme-images/app-img.png">

## Architecture Diagram

<img src="./readme-images/my-arch.drawio.png">

## File Structure

```
eks-project/
├── app
├── infra
│   ├── bootstrap
│   │   ├── main.tf
│   │   ├── modules
│   │   │   ├── dynamodb
│   │   │   │   ├── main.tf
│   │   │   │   └── variables.tf
│   │   │   ├── ecr
│   │   │   │   ├── main.tf
│   │   │   │   └── variables.tf
│   │   │   └── s3
│   │   │       ├── main.tf
│   │   │       └── variables.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfstate
│   │   ├── terraform.tfstate.backup
│   │   └── variables.tf
│   ├── main.tf
│   ├── modules
│   │   ├── eks
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── pod-identity
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   ├── sg
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   └── vpc
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── kubernetes
│   ├── argocd-ingress.yaml
│   ├── argocd.yaml
│   ├── charts
│   │   └── app_chart
│   │       ├── Chart.yaml
│   │       ├── charts
│   │       ├── templates
│   │       │   ├── deployment.yaml
│   │       │   ├── ingress.yaml
│   │       │   └── service.yaml
│   │       └── values.yaml
│   ├── clusterissuer.yaml
│   ├── graphana-ingress.yaml
│   ├── helmfile.yaml
│   └── prometheus-ingress.yaml
```

## Custom VPC
