import json
import os
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def handler(event, context):
    print("Event received:" , event)
    # 1) Handle CORS preflight (OPTIONS)
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "https://d39sv4r25mde6w.cloudfront.net",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
            },
            "body": ""
        }

    # 2) Normal POST
    try:
        body = json.loads(event.get("body") or "{}") 
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "https://d39sv4r25mde6w.cloudfront.net",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
            },
            "body": json.dumps({"error": "Invalid JSON format"})
        }
    
    # Get the score and email from the body 
    totalScore = body.get("totalScore")
    email = body.get("email")
    print("Email:", email, "Score:", totalScore)
    
    if totalScore is None or email is None:
        return {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "https://d39sv4r25mde6w.cloudfront.net",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
            },
            "body": json.dumps({"error": "Missing score or email"})
        }

    user_id = str(uuid.uuid4())

    # Store the quiz results in DynamoDB
    try:
        item = {
            "user_id": user_id,
            "score": totalScore,
            "email": email
        }
        
        table.put_item(Item=item)
        
    except Exception as e:
        print(f"DynamoDB error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "https://d39sv4r25mde6w.cloudfront.net",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
            },
            "body": json.dumps({"error": "Database error"})
        }
    
    response_body = {
        "message": "Result saved successfully!",
        "user_id": user_id,
        "score": totalScore,
        "email": email
    }

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "https://d39sv4r25mde6w.cloudfront.net",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST",
        },
        "body": json.dumps(response_body)
    }

    