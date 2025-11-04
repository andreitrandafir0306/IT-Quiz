# Quiz App on AWS (Serverless Architecture)

This project is a **serverless quiz application** deployed on AWS using **Terraform**.  
It showcases a full end-to-end architecture: static front-end, API backend, serverless compute and persistent storage.

---------------------------------------------------------------------------------------------------------------------

## Architecture Overview

**Frontend**
- **S3 Bucket**: Hosts static assets (HTML, CSS, JS).
- **CloudFront Distribution**: Provides global CDN caching and HTTPS access.  
  - Uses **Origin Access Control (OAC)** for secure S3 access.
  - Has an **API Gateway origin** for dynamic requests.

**Backend**
- **API Gateway**: Handles client requests with:
  - `OPTIONS` (CORS preflight)
  - `POST` (quiz submission)  
  - **MOCK integration** for testing
  - **Lambda proxy integration** for dynamic requests

- **AWS Lambda**: Processes quiz submissions, parses the request body and stores results in DynamoDB.

- **DynamoDB**: Stores quiz results, including:
  - `user_id` (UUID)
  - `email`
  - `score`

---------------------------------------------------------------------------------------------------------------------

## Tech Stack

- **Infrastructure as Code**: Terraform  
- **Compute**: AWS Lambda (Python 3.13)  
- **API**: Amazon API Gateway  
- **Database**: Amazon DynamoDB  
- **Frontend Hosting**: Amazon S3 + CloudFront  
- **Language**: Python (backend), JavaScript (frontend)  

---------------------------------------------------------------------------------------------------------------------

## Project Structure

├── frontend/backend
│ ├── index.html
│ ├── index.css
│ ├── index.js
| ├── config.js (will be created after provisioning infra with TF to be used as env var for API Gateway in JS)
│ ├── function.py
│
├── terraform/
│ ├── API.tf
│ ├── S3.tf
│ ├── DynamoDB.tf
│ ├── Cloudfront.tf
│ ├── Lambda.tf
│ ├── DynamoDB.tf
│ ├── function.zip
│ ├── variables.tf
│
└── README.md
└── .devcontainer


---------------------------------------------------------------------------------------------------------------------

## How It Works

1. User opens the quiz frontend hosted on CloudFront.
2. Quiz answers are collected and scored in the browser (JavaScript).
3. On submission:
   - The frontend sends a `POST` request to the API Gateway.
   - API Gateway invokes a Lambda function.
   - Lambda validates the request and stores the data in DynamoDB.
4. User receives confirmation that the result has been saved.

---------------------------------------------------------------------------------------------------------------------

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)  
- AWS account with sufficient IAM permissions  
- [AWS CLI](https://docs.aws.amazon.com/cli/) configured with credentials  

---------------------------------------------------------------------------------------------------------------------

## Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/andreitrandafir0306/IT-Quiz.git
   cd IT-Quiz/Terraform

2. Set up Terraform:
   ```bash
   terraform init && terraform plan && terraform validate && terraform apply -auto-approve

3. Access the app by inputting the Cloudfront domain name in the browser

---------------------------------------------------------------------------------------------------------------------

## Work in Progress

- Email feature:

Planned functionality to send the end-user an email with:

1. Their score

2. Which questions they answered correctly

3. Which questions were incorrect
