# ECS Healthcheck Service on AWS  
**ECS Fargate · Application Load Balancer · Terraform · Containerised Application**

---

## Project Overview

This project demonstrates the deployment of a lightweight, containerised healthcheck service on AWS using **Amazon ECS (Fargate)** and an **Application Load Balancer**, with infrastructure fully defined using **Terraform**.

The focus of this repository is not just deployment, but understanding how a production-style container platform is built end-to-end — from local development, to containerisation, to managed AWS infrastructure.

While the application itself is intentionally minimal, the surrounding infrastructure mirrors real-world patterns used in modern DevOps and Cloud Engineering environments.

---

## What This Project Covers

At its current stage, the project includes:

- A locally developed application exposing a `/health` endpoint
- Containerisation using Docker with a small, non-root runtime image
- Image storage in Amazon Elastic Container Registry (ECR)
- Manual AWS deployment (ClickOps) to understand ECS, ALB, and networking
- A full rebuild of the same infrastructure using Terraform
- Modular Terraform design for clarity and reuse
- A publicly accessible service behind an ALB with health checks and HTTPS

This repository reflects an **incremental learning approach**, building each layer only after understanding the one below it.

---

## Architecture Summary

At a high level, the application flow is:

- The containerised application runs as ECS tasks on AWS Fargate
- An ECS service maintains the desired number of running tasks
- An Application Load Balancer acts as the public entry point
- A target group performs health checks against `/health`
- Only healthy tasks receive traffic
- Infrastructure is managed and versioned using Terraform

---

## Infrastructure as Code

All AWS resources are defined using Terraform, following a modular structure to keep responsibilities isolated and readable.

The infrastructure includes:

- Custom VPC and networking
- ECS cluster, task definition, and service
- Application Load Balancer with listeners and target group
- Amazon ECR for container images
- ACM for TLS certificates
- IAM roles and permissions required for ECS execution

Manual AWS resources were intentionally created and destroyed first to build a solid mental model before being automated.

---

## Repository Structure

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/fcff769d-aa04-41d4-9be4-f4a4e1e2173b" />

---

## Current Status

- Application runs locally and in a container
- Image is stored in ECR
- Service is deployed on ECS Fargate
- ALB health checks are passing
- Application is reachable via a public HTTPS endpoint
- Infrastructure is fully reproducible with Terraform

---

## Next Steps

Planned next phases include:

- CI/CD automation using GitHub Actions
- Image versioning and automated deployments
- OIDC-based authentication for AWS access (no static credentials)
- Post-deployment health validation
- Additional monitoring using Gatus

---

This project is actively evolving and is intended to reflect real-world DevOps workflows rather than a single static deployment.


