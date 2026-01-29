# GitOps EKS Deployment Project

### In this project I deploy a containerised app using Docker onto AWS EKS with Infrastructure as Code using Terraform, and automate developer changes using GitHub Actions as my CI/CD. I also use helm charts such as NGINX Ingress Controller, External (Dynamic) DNS for automating DNS records, Cert Manager for automated TLS, ArgoCD for GitOps methodoloy, and Prometheus and Graphana for monitoring and observability

## Project Overview

Application containerised using Docker to run consistently in all environments.

VPC with 3 Availability zones in region eu-west-2, public and private subnets, route tables, regioinal NAT gateway, VPC flow logs

EKS cluster security groups for:

- Nodes accepting traffic from cluster SG
- kubelet accepting traffic from cluster SG (on port 10250)
- node to node traffic TCP/UDP

External DNS for dynamic DNS records for App, Argocd, Prometheus, Graphana

Cert Manager for automated TLS encryption

ArgoCD for GitOps driven architecture

Prometheus and Graphana for monitoring and observability
