import json
import boto3
import os
import uuid

dynamodb = boto3.resource("dynamodb")
table_name = os.environ["TABLE_NAME"]
table = dynamodb.Table(table_name)

def handler(event, context):
    try:
        body = json.loads(event["body"])  # API Gateway sends payload in event["body"]

        #email = body.get("email")
        score = body.get("score")

        #if not email or score is None:
        if score is None:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing email or score"})
            }

        # Put item in DynamoDB
        table.put_item(
            Item={
                "user_id": str(uuid.uuid4()),
                "score": score
            }
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Result saved successfully!" "user_id": user_id})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
