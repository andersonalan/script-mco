#!/bin/bash

#Variáveis
tomcat_name="mco"
name_user="marconsoft"

#Diretórios
sh_dir=$(pwd)
base_dir="/marconsoft"
tomcat_dir="$base_dir/tomcat_$tomcat_name"
mco_configuration_dir="$base_dir/configuration/$tomcat_name".
mco_log_dir="$base_dir/logs/$tomcat_name"

#Variáveis Database
database="mco"
database_user="mco"

#Variáveis Tomcat
tomcat_service="tomcat.service"
tomcat_targz="tomcat.tar.gz"
port="9090"
port_shutdown="9095"

#Variáveis E-Mail
mail_host="host"
mail_port="9090"
mail_username="manuca"
mail_password="123"
mail_ssl="ssl"

#Variáveis de parâmetros Postgres
max_connections='100'
shared_buffers='512MB'
effective_cache_size='1536MB'
maintenance_work_mem='128MB'
checkpoint_completion_target='0.9'
wal_buffers='16MB'
default_statistics_target='100'
random_page_cost='1.1'
effective_io_concurrency='200'
work_mem='1310kB'
min_wal_size='1GB'
max_wal_size='4GB'

#Script
echo "Tornando o pop-up de restart do Ubuntu automático"
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

echo "# Atualizando a lista de pacotes"
sudo apt update 

echo "# Atualizando os pacotes"
sudo apt upgrade -y

echo "# Instalando zip e unzip"
sudo apt install zip -y

echo "# Criando a configuração do repositório de arquivos"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

echo "# Importando a chave de assinatura do repositório"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "# Atualizando a lista de pacotes"
sudo apt update

echo "# Instalando a versão mais recente do Postgres"
sudo apt -y install postgresql

echo "# Atualizando a lista de pacotes"
sudo apt update 

echo "# Instalando JAVA 8"
sudo apt install -y openjdk-8-jdk-headless

echo "# Atualizando a lista de pacotes"
sudo apt update 

echo "# Criando as senhas do usuário postgres e do banco de dados mco"
password_postgres=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
password_db=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)

echo "# Criando o usuário"
sudo adduser -disabled-password --gecos "" $name_user

echo "# Alterando a senha do usuário"
password_user=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
echo -e "$password_user\n$password_user" | sudo passwd $name_user
echo "# A senha do usuário $name_user é $password_user"

echo "# Criando o diretório"
mkdir $base_dir

echo "# Download do tomcat"
wget -O "$base_dir/$tomcat_targz" https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz

echo "# Extraindo tomcat"
tar -xzf $base_dir/$tomcat_targz -C $base_dir

echo "# Alterando o nome do diretório"
sudo mv $base_dir/apache-tomcat-9.0.21 $tomcat_dir
sudo rm -r $tomcat_dir/webapps/*

echo "# Extraindo a aplicação"
sudo unzip template/mco/application/ROOT.war -d $tomcat_dir/webapps/ROOT

mkdir -p $mco_configuration_dir

for i in $sh_dir/template/mco/config/* 
do
    file_name=$(echo ${i##*/})
    eval "echo \"$(cat $sh_dir/template/mco/config/$file_name)\"" > $mco_configuration_dir/$file_name
done

rm $tomcat_dir/conf/server.xml

eval "echo \"$(cat $sh_dir/template/tomcat/server.xml)\"" > $tomcat_dir/conf/server.xml

echo "# Criando o tomcat.service"
eval "echo \"$(cat template/service/tomcat.service)\"" > /etc/systemd/system/$tomcat_service

echo "# Atualizando as informações do tomcat.service"
systemctl daemon-reload

echo "# Habilitando e iniciando o tomcat"
systemctl enable $tomcat_service

echo "# Permissão para a pasta"
chmod 770 $base_dir -R

echo "# Colocando o usuário e o grupo marconsoft como o dono da pasta"
chown $name_user $base_dir -R
chgrp $name_user $base_dir -R

echo "# Alterando para o diretório /"
cd /

echo "# Adicionando a senha criada anteriormente de acesso ao usuário postgres"
sudo -u postgres psql -c "alter user postgres with password '$password_postgres';"

echo "# Parando o Postgres"
systemctl stop postgresql

echo "# Alrando o arquivo pg_hba"
rm /etc/postgresql/15/main/pg_hba.conf
cp $sh_dir/template/postgres/pg_hba.conf /etc/postgresql/15/main/pg_hba.conf

echo "# Iniciando o Postgres"
systemctl start postgresql

echo "# Criando a database mco o usuário mco e garantindo todos os privilégios para o usuário mco"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "CREATE DATABASE $database"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "CREATE USER $database_user WITH PASSWORD '$password_db';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "GRANT ALL PRIVILEGES ON DATABASE $database TO $database_user;"

echo "# Alterando os parâmentros do sistema do Postgres"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET max_connections = '$max_connections';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET shared_buffers = '$shared_buffers';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET effective_cache_size = '$effective_cache_size';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET maintenance_work_mem = '$maintenance_work_mem';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET checkpoint_completion_target = '$checkpoint_completion_target';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET wal_buffers = '$wal_buffers';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET default_statistics_target = '$default_statistics_target';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET random_page_cost = '$random_page_cost';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET effective_io_concurrency = '$effective_io_concurrency';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET work_mem = '$work_mem';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET min_wal_size = '$min_wal_size';"
psql -U postgres -h 127.0.0.1 password=$password_postgres -c "ALTER SYSTEM SET max_wal_size = '$max_wal_size';"

echo "# Criando o arquivo de senhas"
echo "senha usuário: $password_user" > /home/marconsoft/senha.txt
echo "senha usuário postgres: $password_postgres" >> /home/marconsoft/senha.txt
echo "senha usuário mco: $password_db" >> /home/marconsoft/senha.txt

echo "# Restaurando a database"
unzip $sh_dir/template/mco/database/mco.backup.zip -d $sh_dir 

echo "# Criando o backup para a database mco e removendo o arquivo .backup"
psql -U postgres -h 127.0.0.1 password=$password_postgres $database < $sh_dir/mco.backup
rm $sh_dir/mco.backup

systemctl start $tomcat_service
 
