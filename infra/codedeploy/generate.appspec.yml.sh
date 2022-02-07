#!/bin/sh
cat <<EOF > appspec.yml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "${PATH}"
EOF