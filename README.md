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

## GitOps Architecture with ArgoCD

The app manifests get deployed via a custom helm chart dynamically through ArgoCD. GitOps is the practice where Git/GitHub is the source of truth for the manifests.

I specify my GitHub repo and the file path to my applications Helm chart, and ArgoCD manages the updates, all I need to do is push updates to Git.

<img src="./readme-images/my-argocd.png">

## Prometheus for scarping metrics from EKS cluster

Prometheus is used as the primary monitoring system for the EKS cluster and deployed workloads. It continuously scrapes metrics from Kubernetes components, nodes, and application pods, storing them as time-series data for observability

In this project, Prometheus is deployed via a Helm chart and configured to automatically discover and scrape metrics from the EKS cluster

<img src="./readme-images/prometheus.png">

Grafana is integrated with Prometheus as a data source and is used to visualise metrics through dashboards. Dashboards display real-time insights such as:

- Node and pod resource usage
- Cluster capacity and health
- Application availability and performance
- Request and error metrics

<img src="./readme-images/graphana.png">
