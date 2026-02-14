# Gatus Health Monitoring Platform on AWS ECS Fargate (AWS, Terraform, CI/CD)

![AWS ECS Fargate](https://img.shields.io/badge/AWS-ECS%20Fargate-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=FF9900)
![Terraform IaC](https://img.shields.io/badge/Terraform-IaC-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=7B42BC)
![GitHub Actions CI/CD](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=0A66C2)
![Docker Containers](https://img.shields.io/badge/Docker-Containers-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=5BC0EB)
![Security OIDC](https://img.shields.io/badge/Security-OIDC-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=2E7D32)
![IAM Least Privilege](https://img.shields.io/badge/IAM-Least%20Privilege-6e6e6e?style=for-the-badge&labelColor=6e6e6e&color=FF6A00)



A production-style container platform deployed on **AWS ECS Fargate**, using **Terraform** for infrastructure-as-code and **GitHub Actions** for secure CI/CD.  
The application runs **Gatus** behind an **Application Load Balancer (ALB)** with **HTTPS and a custom domain**, providing real-time health monitoring for internal and external services.


The platform runs inside a custom AWS VPC and follows standard AWS reference architecture patterns:

- Users access the platform via a custom domain over HTTPS
- Traffic flows through Cloudflare to an Application Load Balancer
- ECS Fargate runs the Gatus container in private subnets
- NAT Gateway provides outbound-only internet access
- Logs are streamed to CloudWatch
- CI/CD pipelines build and deploy images automatically


<p align="center">
  <img src="./assets/architecture.png" alt="ECS Fargate Architecture Diagram" width="900" />
</p>

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Local Development](#local-development)
- [Design Priorities](#design-priorities)
- [Architecture Overview](#architecture-overview)
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
- Remote state stored in Amazon S3 (backend)
- State locking enabled using S3 lockfile (`use_lockfile = true`)
- Bootstrap stack provisions foundational resources (IAM, ECR, S3 backend)


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

## Local Development

This project uses the open-source Gatus monitoring engine:
```
https://github.com/TwiN/gatus
```
### Clone this repository

```bash
git clone https://github.com/Param2ray/ecs-production-healthcheck-service.git
cd ecs-production-healthcheck-service
```
### Run locally (Go)
```
cd app
go mod download
go run .
```
Verify:
```
curl http://localhost:8080/health
```
Expected response:
```
{"status":"UP"}
```
### Run locally with Docker

```
docker build -t gatus-local -f Docker/Dockerfile .
```
```
docker run -p 8080:8080 gatus-local
```
Verify:
```
curl http://localhost:8080/health
```


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

## Repository Structure
```
ecs-production-healthcheck-service/
├── .github/
│   └── workflows/
│       ├── build.yml            # Docker build, scan & push to ECR
│       ├── plan.yml             # Terraform plan (manual)
│       ├── apply.yml            # Terraform apply + post-deploy health check
│       └── destroy.yml          # Guarded teardown workflow
│
├── assets/
│   └── architecture.png         # Architecture diagram
│
├── app/                         # Gatus application source
│
├── config/                      # Gatus health check configuration
│
├── Docker/
│   ├── Dockerfile               # Multi-stage Docker build (optimized)
│   └── .dockerignore
│
├── terraform/                   # Runtime infrastructure
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── terraform.auto.tfvars
│   └── modules/
│       ├── vpc/
│       ├── alb/
│       ├── ecs/
│       ├── iam/
│       ├── acm/
│       └── domain/
│
├── terraform-bootstrap/         # One-time foundational resources (IAM, ECR, S3 backend)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── versions.tf
│
├── README.md
└── .gitignore

```

---
## CI/CD Workflow

All pipelines authenticate to AWS using GitHub OIDC federation.  
No static AWS credentials are stored in GitHub.

---

### Docker Build & Push (`build.yml`)

- Triggered on application changes
- Builds multi-stage Docker image
- Tags image with commit SHA
- Scans image with **Trivy**
- Pushes image to Amazon ECR
- Fails on HIGH/CRITICAL vulnerabilities

<img width="295" height="203" alt="build" src="https://github.com/user-attachments/assets/03c5b6ae-78ee-4ca2-8549-8ec3ba3fc809" />


---

### Terraform Plan (`plan.yml`)

- Manual trigger (`workflow_dispatch`)
- Runs **Checkov** for security validation
- Validates Terraform configuration
- Generates execution plan for review

<img width="326" height="216" alt="plan" src="https://github.com/user-attachments/assets/7b3abb32-99cc-4cf6-b965-cc108ed71926" />


---

### Terraform Apply (`apply.yml`)

- Manual trigger
- Verifies container image exists in ECR
- Applies infrastructure changes
- Deploys latest image
- Performs automated health check
- Pipeline fails if service is unhealthy

<img width="610" height="233" alt="apply" src="https://github.com/user-attachments/assets/0b533208-c72e-4cb9-8f96-97bb25334aa4" />


---

### Terraform Destroy (`destroy.yml`)

- Manual guarded teardown
- Requires confirmation input ("DESTROY")
- Uses restricted IAM permissions
- Prevents accidental infrastructure deletion

<img width="315" height="220" alt="destroy" src="https://github.com/user-attachments/assets/aae8bebe-5349-455c-b46c-e63704f478c5" />


---

### Security & Validation

- **Trivy** scans container images before push
- **Checkov** validates Terraform security posture
- Failing scans prevent promotion to production

---
## Containers & Runtime

- Multi-stage Docker build
- Minimal runtime image
- Non-root container execution
- Reduced attack surface
- Optimised for ECS Fargate execution

### Docker Optimisation Result

Baseline image: **2.55GB**  
Optimised image: **80.4MB**

**2.55GB → 80.4MB (~97% reduction)**

Achieved using:
- Multi-stage build
- Distroless-style runtime
- Removal of unnecessary tooling
- Smaller attack surface


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
- State locking enabled using S3 lockfile (`use_lockfile = true`)  
- Bootstrap stack provisions foundational resources (IAM, ECR, S3 backend bucket)  

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
---
<img width="1920" height="1032" alt="1 dashboard" src="https://github.com/user-attachments/assets/1525dcf3-6560-4932-96b5-2e53d533ae7a" />
<img width="1920" height="1032" alt="2 dashboard" src="https://github.com/user-attachments/assets/a484580e-4466-41c7-8aea-3f542262be4c" />
<img width="1920" height="1032" alt="3 dashboard" src="https://github.com/user-attachments/assets/c24ae7e4-ff17-43a4-80da-979d14ece70a" />
<img width="1920" height="1032" alt="4 dashboard" src="https://github.com/user-attachments/assets/a4a4d2c8-9a39-4b99-8484-1df8fb7de6b6" />


---

## Live Demo

**Health Dashboard:**  
https://tm.paramjyot2ray.com

**Health Endpoint:**  
https://tm.paramjyot2ray.com/health

![HealthDashboard_Gatus-GoogleChrome2026-02-0821-38-49-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/0b31d164-bde4-4bf2-9e25-e23b50e5070f)

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


