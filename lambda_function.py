import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Resumes')

def lambda_handler(context):
    resume_id = '1'
    
    try:
        response = table.get_item(Key={'id': resume_id})
        item = response.get('Item')
        if item:
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'message': 'Resume not found'})
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error', 'error': str(e)})
        }