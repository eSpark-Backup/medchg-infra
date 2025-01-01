kubectl create namespace argocd
kubectl apply -n argocd -f deploy.yaml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
