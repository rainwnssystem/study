cat <<EOF >> ~/.bashrc >> ~/.zshrc
alias ka="kubectl apply"
alias kd="kubectl describe"
alias kx="kubectl delete"
alias kg="kubectl get"
alias kl="kubectl logs"
alias kc="kubectl create"
alias kns="kubens"
alias t="terraform"
alias ti="terraform init"
alias ta="terraform apply"
alias taa="terraform apply --auto-approve"
alias to="terraform output"
alias qi="q i"
alias qc="q c"
EOF

source ~/.bashrc
source ~/.zshrc