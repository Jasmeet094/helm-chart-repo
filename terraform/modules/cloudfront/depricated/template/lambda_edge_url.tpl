import boto3
import logging
import os

logging.getLogger().setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    table_name =  "${tablename}"
    
    request = event['Records'][0]['cf']['request']
    key = event['Records'][0]['cf']['request']['uri']

    logging.info(f"Entered `lambda_edge_url` with event: {event}")
    logging.info(f"Entered `table_name` with event: {table_name}")

    dynamodb = boto3.client("dynamodb", region_name="us-east-1")
    response = dynamodb.update_item(
        TableName=table_name,
        Key={"siteUrl": { "S": key }},
        UpdateExpression="SET visits = if_not_exists(visits, :zero) + :inc",
        ExpressionAttributeValues={":inc":{"N":"1"}, ":zero":{"N":"0"}},
        ReturnValues="UPDATED_NEW",
    )
    
    logging.info(f"Updated Item `{key}` with response: {response}")
    
    response_http_status_code = response['ResponseMetadata']['HTTPStatusCode']
    
    logging.info(f"Returning `{response_http_status_code}`")
    
    return request 
