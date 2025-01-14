# create secret one time 
kubectl create namespace stg-ns-medchg  

kubectl create secret docker-registry regcred \
    --docker-server=839119967592.dkr.ecr.us-east-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region us-east-1) \
    --docker-email=shahmeer@esparkconsultants.com --namespace stg-ns-medchg
	
	
kubectl get secret medchg-fullstack -n stg-ns-medchg -o jsonpath='{.data.tls\.crt}' | base64 -d > stg.medchg.com.crt
kubectl get secret medchg-fullstack -n stg-ns-medchg -o jsonpath='{.data.tls\.key}' | base64 -d > stg.medchg.com.key
openssl pkcs12 -export -out stg.medchg.com.pfx -inkey stg.medchg.com.key -in stg.medchg.com.crt

kubectl create secret generic dev-sc-identity-ssl -n stg-ns-medchg --from-file=certificate=./stg.medchg.com.pfx
	