#!/bin/bash

STACK_PREFIX="Brandon"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


deleteStackWait() {
  declare stack=${1:? required stackName}
  aws cloudformation delete-stack --stack-name $stack
  echo "---> wait for stack delete: ${stack} ..."
  aws cloudformation wait stack-delete-complete --stack-name $stack
}

vpc(){
  deleteStackWait ${STACK_PREFIX}-EKS-VPC
}

eks-cluster(){
  deleteStackWait ${STACK_PREFIX}-EKS-Cluster
}

$@