kubectl create secret docker-registry regcred \
    --docker-server=839119967592.dkr.ecr.us-east-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region us-east-1) \
    --docker-email=shahmeer@esparkconsultants.com --namespace prod-test1