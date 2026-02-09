# ECS Fargate Health Monitoring Platform (AWS, Terraform, CI/CD)

<strong>
<span style="color:#FF9900;">AWS ECS Fargate</span> ·
<span style="color:#7B42BC;">Terraform</span> ·
<span style="color:#2088FF;">GitHub Actions</span> ·
<span style="color:#2ECC71;">Gatus</span>
</strong>

A production-style container platform deployed on **AWS ECS Fargate**, using **Terraform** for infrastructure-as-code and **GitHub Actions** for secure CI/CD.  
The application runs **Gatus** behind an **Application Load Balancer (ALB)** with **HTTPS and a custom domain**, providing real-time health monitoring for internal and external services.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Design Priorities](#design-priorities)
- [Architecture Overview](#architecture-overview)
- [Architecture Diagram](#architecture-diagram)
- [Repository Structure](#repository-structure)
- [CI/CD Workflow](#cicd-workflow)
- [Containers & Runtime](#containers--runtime)
- [IAM & Least Privilege Access](#iam--least-privilege-access)
- [Terraform & State Management](#terraform--state-management)
- [Observability](#observability)
- [Live Demo](#live-demo)
- [Future Improvements](#future-improvements)
- [What This Project Demonstrates](#what-this-project-demonstrates)

---

## Overview

This project demonstrates an end-to-end **ECS Fargate deployment** following real-world DevOps practices:

- Containerised application
- HTTPS via ALB + ACM
- Infrastructure defined entirely in Terraform
- CI/CD pipelines using GitHub Actions with OIDC (no static AWS credentials)
- Live health monitoring using Gatus

The emphasis is on **clarity, security, and operational correctness**, rather than unnecessary complexity.

---

## Tech Stack

### Cloud & Infrastructure
- AWS ECS (Fargate)
- Application Load Balancer (ALB)
- Amazon ECR
- AWS Certificate Manager (ACM)
- Amazon VPC
- CloudWatch Logs

### Infrastructure as Code
- Terraform
- Modular Terraform design
- S3 backend with DynamoDB state locking

### CI/CD
- GitHub Actions
- OIDC authentication (no long-lived AWS keys)

### Application & Runtime
- Gatus (Go-based monitoring tool)
- Docker (multi-stage build)
- Non-root container runtime

### DNS & HTTPS
- Cloudflare (DNS)
- Custom domain with HTTPS

---

## Design Priorities

- Infrastructure defined as code (no ClickOps drift)
- Secure CI/CD using OIDC
- Least-privilege IAM roles
- Immutable container images (SHA-tagged)
- Simple, explainable architecture
- Production-style deployment flow

---

## Architecture Overview

The platform runs inside a custom AWS VPC and follows standard AWS reference architecture patterns:

- Users access the platform via a custom domain over HTTPS
- Traffic flows through an Application Load Balancer
- ECS Fargate runs the Gatus container
- Health checks monitor frontend, backend, internal, and external services
- Logs are streamed to CloudWatch
- CI/CD pipelines build and deploy images automatically

---

## Architecture Diagram

> 📌 **Placeholder – add your final architecture diagram here**

---

## Repository Structure

```text
ecs-production-healthcheck-service/
├── .github/
│   └── workflows/
│       ├── build.yml          # Build + scan + push to ECR
│       ├── deploy.yml         # Terraform apply + health check
│       └── destroy.yml        # Controlled teardown
│
├── app/                       # Gatus application source
│
├── config/                    # Gatus health check configuration
│
├── Docker/
│   ├── Dockerfile             # Multi-stage Docker build
│   └── .dockerignore
│
├── terraform/                 # Runtime infrastructure
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── terraform.auto.tfvars
│   ├── versions.tf
│   └── modules/
│       ├── vpc/
│       ├── alb/
│       ├── ecs/
│       ├── acm/
│       └── domain/
│
├── terraform-bootstrap/       # One-time foundational resources
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── versions.tf
│
├── README.md
└── .gitignore
```
## CI/CD Workflow

### Docker Build & Push (`build.yml`)

- Triggered on application changes  
- Builds a multi-stage Docker image  
- Tags image with commit SHA  
- Pushes image to Amazon ECR  
- Authenticates using GitHub OIDC (no static AWS keys)

### Terraform Deploy (`deploy.yml`)

- Triggered manually via `workflow_dispatch`  
- Applies infrastructure changes using Terraform  
- Deploys the latest container image  
- Performs a post-deploy health check  
- Pipeline fails if the service is unhealthy

### Terraform Destroy (`destroy.yml`)

- Manual, guarded teardown workflow  
- Uses restricted IAM permissions  
- Prevents accidental infrastructure deletion

---

## Containers & Runtime

- Multi-stage Docker build for minimal runtime image  
- Non-root user enforced inside the container  
- Reduced attack surface by excluding unnecessary tooling  
- Optimised for ECS Fargate execution

---

## IAM & Least Privilege Access

- Dedicated IAM role for CI/CD pipelines  
- Separate ECS task execution role  
- Policies scoped to minimum required permissions  
- IAM configuration fully managed via Terraform

---

## Terraform & State Management

- Modular Terraform structure for clarity and reuse  
- Remote state stored in Amazon S3  
- DynamoDB used for state locking  
- Bootstrap stack provisions backend resources

---

## Observability

- Gatus provides real-time health monitoring  
- Endpoints grouped by:
  - External  
  - Frontend  
  - Backend  
  - Internal  
- ECS task logs shipped to CloudWatch  
- No manual logging configuration required  

> 📌 **Placeholder – add Gatus dashboard screenshots here**

---

## Live Demo

**Dashboard:**  
https://tm.paramjyot2ray.com

**Health Endpoint:**  
https://tm.paramjyot2ray.com/health

> 📌 **Placeholder – add live demo screenshots or GIFs**

---

## Future Improvements

- Multi-environment deployments (dev / prod)  
- Promotion-based CI/CD workflows  
- CloudWatch alarms and metrics  
- Extended alerting integrations  
- Terraform refactoring using `for_each` and maps

---

## What This Project Demonstrates

- Real-world AWS ECS architecture design  
- Secure CI/CD using modern authentication patterns  
- Infrastructure that is easy to audit and reason about  
- Clear separation of concerns across the stack  
- Production-ready DevOps and cloud engineering practices


