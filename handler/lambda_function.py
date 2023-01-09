 #Import boto3 and define ec2 client
import boto3

#Define the contents of your shell script
script = """
echo "Hello World!" > /home/ec2-user/helloworld.txt
pwd >> /home/ec2-user/helloworld.txt
"""
#Define the tag possessed by the EC2 instances that we want to execute the script on
tag='Test'


def lambda_handler(event, context):
    #Define ec2 and ssm clients
    ec2_client = boto3.client("ec2", region_name='us-east-1')
    ssm_client = boto3.client('ssm')
    
    #Gather of instances with tag defined earlier
    filtered_instances = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag]}])
    
    #Reservations in the filtered_instances
    reservations = filtered_instances['Reservations']
    
    #Create a an empty list for instances to execute the shell script within
    exec_list=[]
    
    #Iterate through all the instances within the collected resaervations
    #Append 'running' instances to exec list, ignoring 'stopped' and 'terminated' ones
    for reservation in reservations:
        for instance in reservation['Instances']:
            print(instance['InstanceId'], " is ", instance['State']['Name'])
            if instance['State']['Name'] == 'running':
                exec_list.append(instance['InstanceId'])
        #divider between reservations
        print("**************") 
        
    # Run shell script
    response = ssm_client.send_command(
        DocumentName ='AWS-RunShellScript',
        Parameters = {'commands': [script]},
        InstanceIds = exec_list
    )
        
    #See the command run on the target instance Ids
    print(response['Command']['Parameters']['commands'])
