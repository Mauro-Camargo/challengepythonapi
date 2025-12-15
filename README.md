# 🚀 Serverless API for Infrastructure Automation on AWS

This project implements a **serverless API in Python** designed to automate infrastructure operations on AWS. The initial implementation focuses on **VPC provisioning**, but the main goal is to demonstrate an **extensible automation pattern** that can be expanded to manage different cloud resources.

The API is built using **AWS Lambda**, exposed via **API Gateway**, secured with **Amazon Cognito**, and provisioned using **Terraform**.

---

## 📌 Project Goals

- Expose infrastructure automation through an API
- Combine Python, Serverless and Infrastructure as Code
- Apply security best practices using JWT authentication
- Enable auditability and traceability of infrastructure actions
- Serve as a foundation for internal automation portals and approval workflows

---

## 🧭 Table of Contents

- [Architecture Overview](#-architecture-overview)  
- [Technology Stack](#-technology-stack)  
- [Use Cases](#-use-cases)  
- [Prerequisites](#-prerequisites)  
- [Infrastructure Setup and Deployment](#-infrastructure-setup-and-deployment)  
  - [Fork the Repository](#1-fork-the-repository)  
  - [Configure Terraform Backend](#2-configure-terraform-backend)  
  - [Update the S3 Bucket for Lambda](#3-update-the-s3-bucket-for-lambda)  
  - [Commit Your Changes and Open a Pull Request](#4-commit-your-changes-and-open-a-pull-request)  
- [API Usage](#-api-usage)  
  - [Getting the JWT Token](#getting-the-jwt-token)  
  - [Available Endpoints](#-available-endpoints)  
- [Metadata Persistence](#-metadata-persistence)  
- [CI/CD Pipeline](#-cicd-pipeline)  
- [Project Structure](#-project-structure)  
- [Extending the Automation](#-extending-the-automation)  
- [Contributing](#-contributing)  
- [References](#-references)

---

## 🧩 Architecture Overview

Components:

- Amazon API Gateway  
- AWS Lambda (Python)  
- Amazon Cognito (JWT authentication)  
- Amazon DynamoDB  
- Terraform  
- GitHub Actions

This architecture fits corporate environments where infrastructure actions must be controlled, audited and automated.

---

## 🧰 Technology Stack

- Python 3.x  
- AWS Lambda  
- Amazon API Gateway  
- Amazon Cognito  
- Amazon DynamoDB  
- Terraform  
- GitHub Actions  
- Boto3

---

## 🏢 Use Cases

Integrate this API into internal enterprise portals:

- Developers request infrastructure through a form  
- Requests go through validation and approval workflows  
- After approval, the portal triggers the API  
- Infrastructure is provisioned automatically

Fits ITSM tools such as ServiceNow or Jira Service Management.

---

## ⚙️ Prerequisites

- AWS account  
- AWS CLI configured  
- Terraform ~> 5.0  
- Python 3.x  
- GitHub account

---

## 🛠️ Infrastructure Setup and Deployment

### 1. Fork the Repository

Go to the original repository and click the **Fork** button (if required), then clone your fork and change into the project directory:

```bash
git clone https://github.com/<your-username>/<your-repository>.git
cd <your-repository>
```

### Initialize Terraform

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

### 2. Configure Terraform Backend

This project uses an S3 backend to store the Terraform state remotely. Create an S3 bucket in your AWS account and update the `backend "s3"` section in the `main.tf` file with your bucket name. Ensure the bucket has proper access and lifecycle policies according to your governance rules.

### 3. Update the S3 Bucket for Lambda

The Lambda deployment code is stored in an S3 bucket. Create an S3 bucket in your AWS account and update the `lambda_code_bucket` variable in the `variables.tf` file with your bucket name so Terraform can upload and reference the Lambda package.

### 4. Commit Your Changes and Open a Pull Request

Commit your Terraform and configuration changes to a feature branch, push to the remote repository, and open a pull request to trigger the CI pipeline. The typical flow is:

```bash
git checkout -b feature/terraform-config
git add .
git commit -m "Configure terraform backend and lambda S3 bucket"
git push origin feature/terraform-config
# Open a Pull Request from the branch to main (or the repository's required branch)
```

After the PR is created, the repository's GitHub Actions will run `terraform plan`. Once approved and merged according to your repo process, the `terraform apply` job can run to provision resources.

Terraform outputs will include the API endpoint and Cognito details.

---

## 🔐 API Usage

All endpoints require a valid JWT token issued by Amazon Cognito.

Headers:

- Authorization: Bearer <JWT_TOKEN>  
- Content-Type: application/json

Example request (create VPC):

```http
POST /v1/vpc
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "environment": "dev",
  "cidr_block": "10.0.0.0/16",
  "name": "example-vpc"
}
```

Example response:

```json
{
  "vpc_id": "vpc-0123456789abcdef",
  "status": "created"
}
```

### Getting the JWT Token

Follow the login process with a valid Cognito user to obtain an `IdToken`. You can use the AWS CLI for this:

> ⚠️ Before using the API endpoint, you must configure your Cognito user, because the password defined in the `cognito.tf` file is temporary.

Using AWS CloudShell, run the commands below:

```bash
aws cognito-idp admin-initiate-auth --user-pool-id <YOUR_USER_POOL_ID> --client-id <YOUR_CLIENT_ID> --auth-flow ADMIN_NO_SRP_AUTH --auth-parameters USERNAME=challengeuser,PASSWORD=Challenge2025!
```

The above command returns a session token. Copy it and use it in the next command:

```bash
aws cognito-idp admin-respond-to-auth-challenge --user-pool-id <YOUR_USER_POOL_ID> --client-id <YOUR_CLIENT_ID> --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses 'NEW_PASSWORD=<PutYourNewPassword>,USERNAME=challengeuser' --session "<PUT_YOUR_SESSION_TOKEN>"
```

With this information, you can configure your HTTP client to make requests. An example Postman/Insomnia collection is available in the `CollectionExample` folder of this project.

---

## 📌 Available Endpoints

| Method | Endpoint         | Description                                                |
|--------|------------------|------------------------------------------------------------|
| POST   | `/vpcs`          | Creates a new VPC with subnets. Requires a JSON body.      |
| GET    | `/vpcs`          | Retrieves the details of a specific VPC.                   |


---

## 🗄️ Metadata Persistence

Each infrastructure operation stores metadata in DynamoDB, including:

- environment  
- resource_id  
- action  
- user_id (or principal)  
- timestamp  
- status

This enables auditability and traceability.

---

## 🤖 CI/CD Pipeline

GitHub Actions performs:

- terraform fmt  
- terraform validate  
- terraform plan  
- terraform apply (via pipeline with appropriate approvals)

This enforces infrastructure governance through automation.

---

## 📁 Project Structure

```
.
├── architecture/                 # architecture diagrams and additional docs
├── CollectionExample/            # Postman/Insomnia collections
│   ├── InsomniaChallenge           
├── lambda/                       # Lambda functions grouped by responsibility
│   ├── app.py
│   └── requirements.txt
├── terraform/                    # Terraform configuration (root files)
│   ├── apigateway.tf
│   ├── cognito.tf
│   ├── dynamodb.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── .github/
│   └── workflows/
│       └── terraform.yml         # CI for formatting, validating, planning, apply
├── README.md
└── .git/
```

---

## 🔧 Extending the Automation

The pattern can be extended to:

- Scale Auto Scaling Groups  
- Manage Launch Templates  
- Execute operational actions (reboot, replace)  
- Orchestrate workflows using Step Functions  
- Support multiple environments and accounts

Use the same API + IaC + Lambda pattern to add new actions and resources.

---

## 🤝 Contributing

Contributions are welcome. Open issues or submit pull requests. Follow repository guidelines and CI checks.

---

## 📚 References

- https://docs.aws.amazon.com/lambda/  
- https://docs.aws.amazon.com/apigateway/  
- https://docs.aws.amazon.com/cognito/  
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs