def lambda_handler(event, context):
    import boto3
    
    ec2_client=boto3.client("ec2", region_name='us-east-1')
    
    print("hello")
