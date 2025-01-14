set version prod-v10
echo $version
docker build -t testblazor:$version . 
docker tag testblazor:$version 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:$version
docker push 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:$version

docker run -p 80:80 testblazor:$version