Untuk simulasi dapat menggunakan google cloud platform menggunakan "Compute Engine"

Silakan membuat 3 server dengan OS Ubuntu 18.04 LTS dengan nama sebagai berikut:
- ansible-control
- appserver
- dbserver

============================================================================
Silkan masuk kedalam server ansible-control menggunakan webssh
============================================================================
Pada ansible-control server silakan jalankan command sebagai berikut

sudo apt-get install software-properties-common

echo -ne '\n' | sudo apt-add-repository ppa:ansible/ansible

sudo apt-get update

sudo apt-get install ansible

ansible --version

sudo userdel ansadm

-m untuk membuat user dengan home folder
-d untuk menentukan direktori folder home

sudo useradd -m -d /home/ansadm ansadm

echo -ne "ansadm\nansadm\n" | sudo passwd ansadm

Dengan ini anda berhasil membuat user ansadm dengan password ansadm

Masuk sebagai root ansadm user

su - ansadm

ssh-keygen -t rsa

cat /home/ansadm/.ssh/id_rsa.pub

Silakan copy outputnya dan integrasikan dengan server yang lain sesuai
sesuai dengan video tutorial
===========================================================================================
Silkan masuk kedalam server dbserver menggunakan webssh (atur untuk dbserver dan appserver)
===========================================================================================
sudo userdel ansadm

sudo useradd -m -d /home/ansadm ansadm

echo -ne "ansadm\nansadm\n" | sudo passwd ansadm

Dengan ini anda berhasil membuat user ansadm dengan password ansadm

Masuk sebagai root ansadm user

su - ansadm

mkdir .ssh

chmod 700 .ssh/

chown ansadm:ansadm .ssh/

cd .ssh

vi authorized_keys

chmod 600 authorized_keys

Kemudian copy output dari ansible-control server pada command cat /home/ansadm/.ssh/id_rsa.pub (untuk cara yang lebih elegan dan bagus silakan baca "public key authentication.pdf" pada folder yang sama. Karena pada beberapa kasus sering kali kalau copy secara manual ada kesalahan copy seperti "enter" ikut tercopy dan lebih aman pakai scp.

Untuk pertama kali di server appserver atau dbserver pastikan 

PasswordAuthentication yes

pada file /etc/ssh/sshd_config dan setelah mengubah

sudo service sshd restart

Tujuan nya adalah agar ssh pertama kita bisa menggunakan password

===============================================================================
Kembali ke ansible-control server
===============================================================================
Tambahkan di /etc/hosts menggunakan internal ip yang ada pada compute engine

lakukan ssh ke dbserver dan appserver

pastikan berhasil
===============================================================================

sudo chown -R ansadm:ansadm /etc/ansible
