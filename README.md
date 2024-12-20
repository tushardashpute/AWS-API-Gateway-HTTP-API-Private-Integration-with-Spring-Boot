# AWS-API-Gateway-HTTP-API-Private-Integration-with-Spring-Boot

This repository provides guidance and examples for setting up AWS API Gateway HTTP API Private Integrations. This integration enables API Gateway to interact with resources inside a VPC, such as an Amazon ECS service, Application Load Balancer (ALB), Network Load Balancer (NLB), or private endpoint.

![image](https://github.com/user-attachments/assets/ed1b5fd2-7c37-48dc-8304-86cdb32ca141)

You use the AWS Management Console. For an AWS CloudFormation template that creates this API and all related resources, see spring_template.yaml.

Here’s a README for the AWS API Gateway HTTP API private integration, based on the documentation:  

# AWS API Gateway HTTP API Private Integration  

This repository provides guidance and examples for setting up **AWS API Gateway HTTP API Private Integrations**. This integration enables API Gateway to interact with resources inside a VPC, such as an Amazon ECS service, Application Load Balancer (ALB), Network Load Balancer (NLB), or private endpoint.  

## Table of Contents  


1. Create an Amazon ECS service
2. Create a VPC link
3. Create an HTTP API
4. Create a route
5. Create an integration
6. Test your API
7. Clean up

## 1. Create an Amazon ECS service

To create an AWS CloudFormation stack
Open the AWS CloudFormation console at https://console.aws.amazon.com/cloudformation.

Choose Create stack and then choose With new resources (standard).

For Specify template, choose Upload a template file.

Select the template that you downloaded.

Choose Next.

For Stack name, enter http-api-private-integrations-tutorial and then choose Next.

For Configure stack options, choose Next.

For Capabilities, acknowledge that AWS CloudFormation can create IAM resources in your account.

Choose Submit

AWS CloudFormation provisions the ECS service, which can take a few minutes. When the status of your AWS CloudFormation stack is CREATE_COMPLETE, you're ready to move on to the next step.

1. [Introduction](#introduction)  
2. [Prerequisites](#prerequisites)  
3. [Architecture Overview](#architecture-overview)  
4. [Setup Guide](#setup-guide)  
    - [Step 1: Create a VPC](#step-1-create-a-vpc)  
    - [Step 2: Configure the Target Service](#step-2-configure-the-target-service)  
    - [Step 3: Create a Private Integration](#step-3-create-a-private-integration)  
    - [Step 4: Deploy the API](#step-4-deploy-the-api)  
5. [Security Considerations](#security-considerations)  
6. [Troubleshooting](#troubleshooting)  
7. [Additional Resources](#additional-resources)  

## Introduction  

AWS API Gateway supports private integrations, allowing you to securely connect to backend services running within a VPC. This setup ensures that your APIs remain private and can only be accessed via specific routes and permissions.  

## Prerequisites  

Before proceeding, ensure you have:  

- An AWS account with administrative access.    
- AWS CLI installed and configured.  

## Architecture Overview  

The private integration establishes connectivity between the API Gateway HTTP API and a target resource within a VPC. The connection is facilitated using:  

- **VPC Links:** API Gateway creates and manages this link to route traffic to private resources.  
- **NLB or Private Endpoints:** These act as targets for API Gateway traffic.  

## Setup Guide  

### Step 1: Create a VPC  

1. Navigate to the **VPC Console**.  
2. Create a new VPC with private and public subnets.  
3. Attach an internet gateway to the public subnet and a NAT gateway to the private subnet (optional).  

### Step 2: Configure the Target Service  

1. Deploy your service within the VPC.  
2. For NLB: Ensure the NLB is in the same VPC as your API Gateway.  
3. Note the private IP addresses and ports used by your backend service.  

### Step 3: Create a Private Integration  

1. Navigate to the **API Gateway Console**.  
2. Create a new HTTP API.  
3. Under **Integrations**, choose **Private Integration**.  
4. Link your API to the backend service using the VPC Link.  

### Step 4: Deploy the API  

1. Deploy the HTTP API to a stage (e.g., `dev`, `prod`).  
2. Configure permissions to control access to your API.  
3. Test the integration by sending requests to your API endpoint.  

## Security Considerations  

- Use IAM policies to restrict API access.  
- Enable logging for API Gateway to monitor traffic and troubleshoot issues.  
- Configure security groups to limit inbound and outbound traffic in your VPC.  

## Troubleshooting  

- **Error: VPC Link is not available:** Ensure the VPC link is properly created and associated with your API.  
- **API not responding:** Check the connectivity between API Gateway and the backend service.  

## Additional Resources  

- [AWS API Gateway HTTP API Documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)  
- [VPC Link Setup](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vpc-links.html)  
- [Network Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)  

--- 

You can customize this further based on specific examples or additional requirements!

