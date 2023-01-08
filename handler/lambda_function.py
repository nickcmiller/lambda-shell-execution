

def lambda_handler(event, context):

#Define the contents of your shell script
script = '''
#!/bin/bash

echo "Hello, World!"
'''


#FINDING INSTANCES TO EXECUTE SCRIPT ON

#Import boto3 and define ec2 client
import boto3
ec2_client = boto3.client("ec2", region_name='us-east-1')
ssm_client = boto3.client('ssm')

instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': ['Test']}])['Reservations'][0]['Instances']

exec_list=[]
for instance in instances:
    exec_list.append(instance['InstanceId'])
    
# Run shell script
response = ssm_client.send_command(
DocumentName='AWS-RunShellScript',
Parameters={'commands': [script]},
InstanceIds=exec_list
)

# Print the command ID
print(response['Command']['CommandId'])
