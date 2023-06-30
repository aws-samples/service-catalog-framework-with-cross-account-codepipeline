# Troubleshooting AWS Code Deploy issues (Draft)

Check the following: 

1. At least one EC2 instance has tags specified by your Code Deployment group information.
2. You ran the ```deploy.sh``` script in the ```target-account``` folder.
3. The profile attached to your EC2 instance has read access to the CodeDeploy bucket

