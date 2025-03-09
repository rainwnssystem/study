#!/bin/bash

# 모든 Pod 이름 가져오기
pods=$(kubectl get pods --no-headers -o custom-columns=":metadata.name")

# 각 Pod에 대해 노드와 zone 정보 가져오기
for pod in $pods; do
  # Pod이 배치된 노드 이름 가져오기
  node=$(kubectl get pod "$pod" -o=jsonpath='{.spec.nodeName}')

  # 노드에 대한 zone 정보 가져오기
  zone=$(kubectl get node "$node" -o=jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}')

  # 결과 출력
  echo "Pod: $pod / Zone: $zone"
done