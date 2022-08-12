# ec2-spot-reclaim-handler

A Lambda Function to handle AWS Spot Instance Reclaim efficiently on Kubernetes workloads

This Lambda function will detach spot instance reclaim node from the Auto Scaling Group when spot reclaim notice is issues, so that Auto Scaling Group would launch a new node to handle the kubernetes workloads. The main purpose is to have new node available on kubernetes as early as possible.

This Lambda function can be used along with [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler) and [Descheduler](https://github.com/kubernetes-sigs/descheduler) where node termination handler will take care of draining all pods on the AWS node which is scheduled for reclaim and descheduler configured on remove duplicates mode would automatically move all the duplicate pods to new node on its next run.

Terraform code is available on [terraform](https://github.com/vkperumal/ec2-spot-reclaim-handler/tree/main/terraform) directory to create all the necessary components for the Lambda Function.

Lambda Function has the option to send notifications using incoming webhooks. To enable webhook modify the environment value on lambda function terraform resource.
