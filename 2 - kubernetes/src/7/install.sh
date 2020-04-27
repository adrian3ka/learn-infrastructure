sudo add-apt-repository multiverse && sudo apt-get update
sudo apt install virtualbox

echo "--------------Check virtual box version-------------"
vboxmanage --version

echo "-----------------Installing kubectl-----------------"
sudo rm /usr/local/bin/kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

./../resource/minikube-linux-amd64 delete

echo "----------------Starting minikube-------------------"

./../resource/minikube-linux-amd64 start

echo "---------------CHECK KUBE VERSION-------------------"
kubectl version
echo "------------------CREATING POD----------------------"
kubectl create -f nginx.yaml

kubectl get pod -o wide

kubectl describe pod nginx

echo "Please run 'kubectl port-forward nginx 8888:80' when status is running"
