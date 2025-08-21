# IT-Quiz

```sh
A simple IT quiz which is using the AWS Infrastructure and a bit of front-end tools.
This project stays entirely in the boundaries of AWS Free Tier because of a very large caveat, often met in real-life workplace environments: Costs, Costs and again ... Costs. Hence, that is why Route 53 or WAF were not used here, although they could make our lives easier.
```

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```sh

User POV:

    1. Login to the interface with e-mail and password, has ability to reset password
    2. Complete the quiz
    3. Receive the results via e-mail
```

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


```sh

Cloud Engineer POV:
    
    Use Terraform to create the following AWS Services:
    
        - S3 Bucket to be used as OAC for the CloudFront Distribution and to store the html, css and js objects for the quiz website
        - CloudFront Distribution to host the website, make it available for the users and cache the content at edge, redirect HTTP trafic to HTTP/S for encryption in transit
        - Security best practices: close public access to the S3 bucket and DynamoDB table, set bucket access level policy for the OAC, IAM Role for API Gateway to invoke Lambda and for the Lambda function to put items in the DynamoDB table
        - Set up API Gateway Rest API to interact with the JS app to grab the email and score and POST them on the API Gateway endpoint
        - Configure the Lambda function, which will be zipped and written in python 3.12
        - Set up CloudWatch logs for observability, monitoring and ensuring that everything can be easily understood and troubleshooted if something goes wrong
        - Set up Cognito for user authentication
        - Provision AWS SES for the emails sent to the users


    Configure CI/CD for automating this task (TBD)
```

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


```sh

Front-end code has been generated with AI since I don't have front-end knowledge.
Docs used: 
    https://docs.aws.amazon.com/ -> AWS Services
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs -> TF IaC
    https://developer.hashicorp.com/terraform/language/values/variables -> TF Variables
```
