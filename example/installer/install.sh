#!/bin/bash -ex


# getStackOutput() {
#     declare desc=""
#     declare stack=${1:?required stackName} outputKey=${2:? required outputKey}

#     aws cloudformation describe-stacks \
# 	--stack-name $stack \
# 	--query 'Stacks[].Outputs[? OutputKey==`'$outputKey'`].OutputValue' \
# 	--out text

# }

# createWorkers() {

#     aws cloudformation create-stack \
# 	--stack-name $WORKER_STACK_NAME  \
# 	--template-body file://$PWD/nodegroup.yml \
#         --capabilities CAPABILITY_IAM \
#         --parameters \
# 	    ParameterKey=NodeInstanceType,ParameterValue=${EKS_NODE_TYPE} \
# 	    ParameterKey=NodeImageId,ParameterValue=${EKS_WORKER_AMI} \
# 	    ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=1 \
# 	    ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=${EKS_NODE_MAX_SIZE} \
# 	    ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=${EKS_SECURITY_GROUPS} \
# 	    ParameterKey=ClusterName,ParameterValue=${EKS_CLUSTER_NAME} \
# 	    ParameterKey=Subnets,ParameterValue=${EKS_SUBNET_IDS//,/\\,} \
# 	    ParameterKey=VpcId,ParameterValue=${EKS_VPC_ID} \
# 	    ParameterKey=KeyName,ParameterValue=dlp-npe-jumpbox

# }

# authWorkers() {

#     EKS_INSTANCE_ROLE=$(getStackOutput  $WORKER_STACK_NAME NodeInstanceRole)

#     cat > /tmp/aws-auth-cm.yaml <<EOF
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapRoles: |
#     - rolearn: ${EKS_INSTANCE_ROLE}
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - system:bootstrappers
#         - system:nodes
# EOF

#     kubectl apply -f aws-auth-cm.yaml
# }


# VPC_STACK_NAME="dlp-npe-vpc"
# EKS_CLUSTER_NAME="dlp-npe-eks-cluster"

# EKS_VPC_ID=$(getStackOutput $VPC_STACK_NAME VPC)
# EKS_SUBNET_IDS=$(getStackOutput $VPC_STACK_NAME PrivateSubnets)
# EKS_SECURITY_GROUPS=$(getStackOutput $EKS_CLUSTER_NAME EKSSecurityGroup)
# EKS_ENDPOINT=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query cluster.endpoint)
# EKS_CERT=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query cluster.certificateAuthority.data)

# WORKER_STACK_NAME="dlp-npe-eks-nodegroups"
# EKS_NODE_TYPE="m3.medium"
# EKS_NODE_MAX_SIZE=3
# EKS_WORKER_AMI="ami-06ade0abbd8eca425"


STACK_PREFIX="Brandon"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

vpc(){
  STACK_NAME=${STACK_PREFIX}-EKS-VPC

  aws cloudformation create-stack \
	--stack-name ${STACK_NAME}  \
	--template-body file://${CURRENT_DIR}/cloudformation/vpc.yml

  aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME}
}

eks-cluster(){
  STACK_NAME=${STACK_PREFIX}-EKS-Cluster

  aws cloudformation create-stack \
	--stack-name ${STACK_NAME}  \
	--template-body file://${CURRENT_DIR}/cloudformation/eks-cluster.yml \
  --capabilities CAPABILITY_NAMED_IAM

  aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME}
}

# eks-worknodes(){

# }


$@

