user="ansadm"

sudo apt-get install software-properties-common

echo -ne '\n' | sudo apt-add-repository ppa:ansible/ansible

sudo apt-get update

sudo apt-get install ansible

ansible --version

sudo userdel $user

sudo useradd $user

echo "$user\n$user\n" | sudo passwd $user

echo "Successfully create user '$user' with password '$user'"
