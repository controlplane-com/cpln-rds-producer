import boto3
# import socket
import os
import dns.resolver

# Constants
NLB_TARGET_GROUP_ARNs = os.environ['NLB_TARGET_GROUP_ARN'].split(',')
SERVICE_FQDNs = os.environ['SERVICE_FQDN'].split(',')
REGION = os.environ['AWS_REGION']
DNS_NAMESERVER = os.environ.get('DNS_NAMESERVER', '169.254.169.253')  # AWS internal DNS


# Initialize Boto3 client
elbv2 = boto3.client('elbv2', region_name=REGION)

def lambda_handler(event, context): 
    
    # Specify the DNS server
    my_resolver = dns.resolver.Resolver()
    my_resolver.nameservers = [DNS_NAMESERVER]  # Configurable DNS server

    output_body = ""

    for NLB_TARGET_GROUP_ARN, SERVICE_FQDN in zip(NLB_TARGET_GROUP_ARNs, SERVICE_FQDNs):
        # Resolve the FQDN to IP addresses
        # current_ips = set(socket.gethostbyname_ex(SERVICE_FQDN)[2])
        # Perform the DNS query for the A records
        answers = my_resolver.resolve(SERVICE_FQDN, 'A')
        current_ips = {answer.to_text() for answer in answers}

        print(f"Working on: {SERVICE_FQDN} - Current IPs: {current_ips}")
        
        # Get the current registered targets
        response = elbv2.describe_target_health(TargetGroupArn=NLB_TARGET_GROUP_ARN)
        registered_ips = {target['Target']['Id'] for target in response['TargetHealthDescriptions']}
        print(f"Current Target Group IPs for {NLB_TARGET_GROUP_ARN}: {registered_ips}")
        
        # Determine IPs to add and remove
        ips_to_add = current_ips - registered_ips
        ips_to_remove = registered_ips - current_ips      
        
        # Register new IPs
        if ips_to_add:
            targets_to_register = [{'Id': ip} for ip in ips_to_add]
            elbv2.register_targets(TargetGroupArn=NLB_TARGET_GROUP_ARN, Targets=targets_to_register)
            print(f"Registered new IPs: {ips_to_add}")
            output_body = f"Update - Registered new IPs for {SERVICE_FQDN}: {ips_to_add}\n"
        
        # Deregister old IPs
        if ips_to_remove:
            targets_to_deregister = [{'Id': ip} for ip in ips_to_remove]
            elbv2.deregister_targets(TargetGroupArn=NLB_TARGET_GROUP_ARN, Targets=targets_to_deregister)
            print(f"Update - Deregistered old IPs for {SERVICE_FQDN}: {ips_to_remove}")
            output_body = f"Update - Deregistered old IPs for {SERVICE_FQDN}: {ips_to_remove}\n"
        
        if not ips_to_add and not ips_to_remove:
            output_body += f"No IP updates for {SERVICE_FQDN}\n"

    if not output_body:
        output_body = "No updates were necessary for any services."

    output_body = output_body.strip()
    print(output_body)

    return {
        'statusCode': 200,
        'body': output_body
    }
