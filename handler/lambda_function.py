#Define the contents of your shell script
script = """
echo "Hello World!" >> /home/ec2-user/helloworld.txt
from the
pwd >> /home/ec2-user/helloworld.txt
"""
#Define the tag possessed by the EC2 instances that we want to execute the script on
tag='Test'


def lambda_handler(event, context):

    #FINDING INSTANCES TO EXECUTE SCRIPT ON
    
    #Import boto3 and define ec2 client
    import boto3
    ec2_client = boto3.client("ec2", region_name='us-east-1')
    ssm_client = boto3.client('ssm')
    
    #Gather a list of Reservations that contain instances with tag
    reservations = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag]}])['Reservations']
    
    #Create a list of instances to execute the shell script within
    exec_list=[]
    
    #Iterate through all the instances within the collected resaervations
    for reservation in reservations:
        print("**************")
        for instance in reservation['Instances']:
            print(instance['InstanceId'])
            print(instance['State']['Name'])
            if instance['State']['Name'] == 'running':
                exec_list.append(instance['InstanceId'])
        
    # Run shell script
    response = ssm_client.send_command(
        DocumentName ='AWS-RunShellScript',
        Parameters = {'commands': [script]},
        InstanceIds = exec_list
    )
        
    #See the command run on the target instance Ids
    print(response['Command']['Parameters']['commands'])
