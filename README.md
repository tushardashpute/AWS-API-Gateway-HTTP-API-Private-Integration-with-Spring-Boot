# AWS-API-Gateway-HTTP-API-Private-Integration-with-Spring-Boot

This repository provides guidance and examples for setting up AWS API Gateway HTTP API Private Integrations. This integration enables API Gateway to interact with resources inside a VPC, such as an Amazon ECS service, Application Load Balancer (ALB), Network Load Balancer (NLB), or private endpoint.

![image](https://github.com/user-attachments/assets/ed1b5fd2-7c37-48dc-8304-86cdb32ca141)

The application architecture includes:

A VPC with public and private subnets.
ECS Fargate service hosting the Spring Boot application.
An internal ALB managing traffic to the Spring Boot application.
AWS API Gateway HTTP API with a VPC link for private integration.

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
7. Create Custom Domain in Gateway API
8. Create Route53 entry for Regional API

## 1. Create an Amazon ECS service

To create an AWS CloudFormation stack
Open the AWS CloudFormation console at https://console.aws.amazon.com/cloudformation.

Choose Create stack and then choose With new resources (standard).

For Specify template, choose Upload a template file.

You can just select the template that you downloaded.[spring_template.yaml] , which creates all of the dependencies for the service, including an Amazon VPC. You use the template to create an Amazon ECS service that uses an Application Load Balancer.

Choose Next.

For the Stack name, enter http-api-private-integrations-tutorial and then choose Next.

For Configure stack options, choose Next.

For capabilities, acknowledge that AWS CloudFormation can create IAM resources for your account.

Choose Submit

AWS CloudFormation provisions the ECS service, which can take a few minutes. When your AWS CloudFormation stack's status is CREATE_COMPLETE, you're ready to proceed to the next step.

As a result of this, you will have an ECS cluster up and running in a VPC.

![image](https://github.com/user-attachments/assets/775265d6-6096-4881-bb5b-8f4046293356)

## 2: Create a VPC link

A VPC link allows API Gateway to access private resources in an Amazon VPC. You use a VPC link to allow clients to access your Amazon ECS service through your HTTP API.

To create a VPC link
Sign in to the API Gateway console at https://console.aws.amazon.com/apigateway.

On the main navigation pane, choose VPC links and then choose Create.

You might need to choose the menu icon to open the main navigation pane.

For Choose a VPC link version, select VPC link for HTTP APIs.

For Name, enter private-integrations-tutorial.

For VPC, choose the VPC that you created in step 1. The name should start with PrivateIntegrationsStack.

For Subnets, select the two private subnets in your VPC. Their names end with PrivateSubnet.

For Security groups, select the Group ID that starts with private-integrations-tutorial and has the description of PrivateIntegrationsStack/PrivateIntegrationsTutorialService/Service/SecurityGroup.

Choose Create.

After you create your VPC link, API Gateway provisions Elastic Network Interfaces to access your VPC. The process can take a few minutes. In the meantime, you can create your API.

![image](https://github.com/user-attachments/assets/7697742d-3917-486d-9136-08e5ff1c9f8f)

## 3: Create an HTTP API

The HTTP API provides an HTTP endpoint for your Amazon ECS service. In this step, you create an empty API. In Steps 4 and 5, you configure a route and an integration to connect your API and your Amazon ECS service.

To create an HTTP API
Sign in to the API Gateway console at https://console.aws.amazon.com/apigateway.

Choose Create API, and then for HTTP API, choose Build.

For API name, enter http-private-integrations-tutorial.

Choose Next.

For Configure routes, choose Next to skip route creation. You create routes later.

Review the stage that API Gateway creates for you. API Gateway creates a $default stage with automatic deployments enabled, which is the best choice for this tutorial. Choose Next.

Choose Create.

![image](https://github.com/user-attachments/assets/3936bd36-335e-4b15-9667-2f5b08f042b1)

## 4: Create a route

Routes are a way to send incoming API requests to backend resources. Routes consist of two parts: an HTTP method and a resource path, for example, GET /items. For this example API, we create one route.

To create a route
Sign in to the API Gateway console at https://console.aws.amazon.com/apigateway.

Choose your API.

Choose Routes.

Choose Create.

For Method, choose ANY.

For the path, enter /{proxy+}. The {proxy+} at the end of the path is a greedy path variable. API Gateway sends all requests to your API to this route.

Choose Create.

![image](https://github.com/user-attachments/assets/4a0f6d81-d4d8-4910-ab3d-240b5f38fb76)

## 5: Create an integration

You create an integration to connect a route to backend resources.

To create an integration
Sign in to the API Gateway console at https://console.aws.amazon.com/apigateway.

Choose your API.

Choose Integrations.

Choose Manage integrations and then choose Create.

For Attach this integration to a route, select the ANY /{proxy+} route that you created earlier.

For Integration type, choose Private resource.

For Integration details, choose Select manually.

For Target service, choose ALB/NLB.

For Load balancer, choose the load balancer that you created with the AWS CloudFormation template in Step 1. It's name should start with http-Priva.

For Listener, choose HTTP 80.

For VPC link, choose the VPC link that you created in Step 2. It's name should be private-integrations-tutorial.

Choose Create.

To verify that your route and integration are set up correctly, select Attach integrations to routes. The console shows that you have an ANY /{proxy+} route with an integration to a VPC Load Balancer.

![image](https://github.com/user-attachments/assets/4664fae1-3488-4255-9271-978b96b3b160)

## 6: Test your API

Note the API ${invoke URL}/listallcustomers and test it:

![image](https://github.com/user-attachments/assets/98915e98-98a4-436f-be20-1d0179b643d5)

![image](https://github.com/user-attachments/assets/47f63710-9155-47f7-bbf9-b088a7f29c49)

If you see the record, you successfully created an Amazon ECS service that runs in an Amazon VPC, and you used an API Gateway HTTP API with a VPC link to access the Amazon ECS service.

## 7. Create Custom Domain in Gateway API

Goto API Gateway --> Custom Domain Name --> Add Domain Name

Enter The Domain name: Here I have a domain **astute001.com**, so I am creating a subdomain with name spring.astute001.com

Attached Certificate from ACM.

Click on Create.

![image](https://github.com/user-attachments/assets/87dd6705-83f4-4540-86f6-f8824adaf86e)


## 8. Create Route53 entry for Regional API

I have already provisioned the hosted zome in my AWS account. Now will add the A record for the regional API gateway endpoint:

![image](https://github.com/user-attachments/assets/1658af6b-98bb-4c81-8775-369d0953cee9)

![image](https://github.com/user-attachments/assets/99373c3b-1642-4829-9428-be874273f2e6)

Now access the spring-boot app using route53 entry:

![image](https://github.com/user-attachments/assets/570bc85d-53aa-4f63-9124-b5aa095ae5f6)

![image](https://github.com/user-attachments/assets/2ec85aa0-7ab3-45b1-a024-cbb60270b5de)



## Additional Resources  

- [AWS API Gateway HTTP API Documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)  
- [VPC Link Setup](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vpc-links.html)  
- [Network Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)  


