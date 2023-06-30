# VPC Parameters
export VPC="vpc-12345678901234567"         # VPC where the Docker container should be deployed
export SubnetA="subnet-12345678901234567"  # Subnet where the Docker container and ALB should be deployed
export SubnetB="subnet-09876543210987654"  # The second subnet.  It must be in a a separate subnet than SubnetA	
# Elastic Container Service Parameters
export Registry=acme                       # The name of the ECR container to use
export Repository=acme                     # The name of the ECR Repository
export ServiceName="HelloWorldJava"        # The name of the ECS Service
export ContainerName="hello-world-java"    # The name of the container to build
export Tag="latest"                        # tag for the container
# Container Parameters
# The CPU/Memory combination for the Docker container. 
# It must be one of the AllowedValues in the CPU/Memory parameters in
# the Fargate.yml template.  
export CPUMemory="512/1GB"
export ContainerPort=8080                 # The exposed port in the Docker container
# Autoscaling Parameters
export MinContainers=1                    # The min number of containers for the ASG
export MaxContainers=2                    # The max number of containers for the ASG
export AutoScalingTargetValue=60          # Try to keep the CPU usage for the service here
export LoadBalancerPort=80                # The port for the load balancer
export HealthCheckPath="/"                # API Path for the health check
# Route53 Parameters - not used
export HostedZoneName="example.com"      
export Subdomain="acme"
# Misc
export FargateStackName="fargate-hello-world"   # CloudFormation stackname for the Fargate container