# Tutorial para instalação de Java 8 / Tomcat 9 / PostgreSQL

Tutorial básico para instalação das ferramentas necessárias para a instalação do sistema MCO no ambiente `Linux`

Requisitos básicos necessários:
- Disponibilidade de um servidor `Linux Ubuntu` (independente da versão);
- Acesso ao servidor `Linux Ubuntu` via o comando `ssh` ou diretamente do servidor; 

Após iniciar o servidor `Ubuntu` e executar o comando `apt update` para atualizar a lista de pacotes
```
sudo apt update
```
Em seguida atualizar os pacotes
```
sudo apt upgrade -y
```
>Finalizado a etapa anterior é possível que seja solicitado o reinicio do serviço  
>Para contiuar utilize o Enter.
___

## Primeiro passo - Instalando Java 8

Instalar o Java Development Kit (JDK), através do comando a seguir:
```
sudo apt -y install openjdk-8-jdk-headless 
```
Para confirmar a instalação executar os comandos `java -version` e `javac -version`.

A instalação do Java 8 está completa!

>Finalizado a etapa anterior é possível que seja solicitado o reinicio do serviço  
>Para contiuar utilize o Enter.
___

## Segundo passo - Instalando Tomcat 9

Antes de iniciar a instalação atualizar o gerenciador de pacotes com o comando:
```
sudo apt update
```
Criar o diretório de instalação do tomcat através dos comandos a seguir.
>Lembrando de estar em modo root.
```
sudo su
```
```
mkdir -p /marconsoft
```
Baixar o instalador `.tar.gz` através do comando `wget` junto ao link do download:  
```
wget -O "/marconsoft/tomcat.tar.gz" https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
```
Extrair o tomcat no diretório criado com o comando:
```
tar -xzf /marconsoft/tomcat.tar.gz -C /marconsoft
```
Alterar o nome do arquivo:
>Como exemplo utilizei o nome "tomcat"
```
mv /marconsoft/apache-tomcat-9.0.21 /marconsoft/tomcat 
```
Para o próximo passo será necessário saber o caminho do `java 8` e para isso utilizar o comando a seguir:
```
update-alternatives --config java
```
Criar o arquivo `tomcat.service` necessário para a inicialização do gerenciador de serviços `systemctl` dentro da pasta `/etc/systemd/system` através do seguinte comando:
```
nano /etc/systemd/system/tomcat.service
```
Abaixo segue o modelo do arquivo, `copiar` o modelo e `colar` dentro do `tomcat.service` pelo programa `nano`:
>Lembrando que caso o caminho das variáveis de ambiente esteja diferente precisa alterar o caminho no arquivo.
```
[Unit]
Description=Apache Tomcat Web Application Container
Wants=network.target
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/

Environment=CATALINA_PID=/marconsoft/tomcat/temp/tomcat.pid  
Environment=CATALINA_HOME=/marconsoft/tomcat/
Environment='CATALINA_OPTS=-Xms512M -Xmx1G -Djava.net.preferIPv4Stack=true'
Environment='JAVA_OPTS=-Djava.awt.headless=true'
Environment='CAMINHO_ARQUIVOS_CONFIGURACAO_MCO_8080=/marconsoft/configuration/mco'

ExecStart=/marconsoft/tomcat/bin/startup.sh
ExecStop=/marconsoft/tomcat/bin/shutdown.sh
SuccessExitStatus=143

RestartSec=10
Restart=always
 
[Install]
WantedBy=multi-user.target
```
>Finalizando as alterações no arquivo, **Ctrl O** e **Enter** para salvar e **Ctrl X** para fechar.

Deletar o `ROOT` padrão e demais diretórios da pasta `webapps`:
```
sudo rm -r /marconsoft/tomcat/webapps/*
```

Extrair o `ROOT.war` do diretório de implantação para o diretório `webapps` do tomcat
```
sudo unzip template/mco/application/ROOT.war -d /marconsoft/tomcat/webapps/ROOT
```
Criar o diretório de `configuração`:

```
mkdir -p /marconsoft/configuration/tomcat
```
Copiar todos os arquivos de configuração para o diretório `configuration`:
```
mv /template/mco/config/* /marconsoft/configuration/tomcat
```
Substituir o arquivo `server.xml` padrão tomcat com o do diretório de implantação:

```
mv /template/tomcat/server.xml /marconsoft/tomcat/conf/server.xml
```

Executar o `systemctl` para habilitar o serviço de inicialização, e para isso utilizar o comando `enable` e depois iniciar com o comando `start`.  
Utilizar o `systemctl daemon-reload` para atualizar as informações do `tomcat.service`.
```
systemctl daemon-reload
```
Habilitar o tomcat via `enable` utilizando o comando:
```
systemctl enable tomcat
```
Depois de habilitado utilizar o comando `start` para iniciar o `tomcat`:
```
systemctl start tomcat
```
Tomcat instalado e serviço de inicialização criado com sucesso!  

Para verificar o status do serviço utilize o comando `status`:
```
systemctl status tomcat
```
___

## Terceiro passo - Criando o usuário Marconsoft 

Antes de iniciar, atualizar o gerenciador de pacotes com o comando:
```
sudo apt update
```
Criar o usuário através do comando:
```
adduser -disabled-password --gecos "" marconsoft
```
Gerar a senha do usuário com os comandos:
```
password_user=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
```
Alterar a senha do usuário Marconsoft para a senha criada
```
echo -e "$password_user\n$password_user" | sudo passwd marconsoft
```
>Exibir a senha do usuário marconsoft
```
echo "A senha do usuário marconsoft é: $password_user"
```
>Salvando o arquivo com a senha:
```
echo "senha usuário: $password_user" > /home/marconsoft/senha.txt
```
Colocar o usuário Marconsoft como dono da pasta /marconsoft
```
chown marconsoft /marconsoft -R
```
Colocar o grupo Marconsoft como dono da pasta /marconsoft
```
chgrp marconsoft /marconsoft -R
```
Alterar a permissão de acesso a pasta /marconsoft para o usuário Marconsoft
```
chmod 770 /marconsoft -R
```
___

## Quarto passo - Instalando PostgreSQL
Antes de iniciar a instalação atualizar o gerenciador de pacotes com o comando:
```
sudo apt update
```
Criar a configuração do repositório de arquivos:
```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
Importar a chave de assinatura do repositório:
```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
Atualizar as listas de pacotes:
```
sudo apt update
``` 
Instalar a versão mais recente do `PostgreSQL`:
```
sudo apt -y install postgresql
```
  
Realizar o ajuste de memória e conexões dentro do arquivo `postgresql.conf` e no arquivo `pg_hba.conf`, respectivamente.
___
### Ajuste de memória e conexões PostgreSQL 

#### Ajuste de memória

Ajustar as configurações de memória do **postgres**, acessando a calculadora de configuração através do link: [PGTune](https://pgtune.leopard.in.ua/ "calculadora de ajuste de memória PostgreSQL"), inserindo os parâmetros da máquina.

> Inserindo os parâmetros da máquina, o site calculará os valores que serão alterados dentro do arquivo `postgresql.auto.conf`.
>
> Como exemplo utilizei os parâmetros abaixo, extraindo a partir da VM do ubuntuserver.

Parameters of your system
- DB version = 15
- OS Type = Linux
- DB Type = Mixed type of application
- Total Memory (RAM) = 1GB
- Number of CPUs = 1
- Number of Connections = 100
- Data Storage = SSD storage

Clicando no botão `Generate` e selecionando a aba `ALTER SYSTEM` a calculadora irá mostrar os comandos para alterar os parâmetros que serão utilizados.  
A seguir copiar todos os comandos de `ALTER SYSTEM SET` através do botão `Copy configuration`.  
Acessar o prompt do `postgres` e executar os parâmetros;  

```
sudo -u postgres psql
```
> Abaixo o resultado do exemplo:
```
ALTER SYSTEM SET
 max_connections = '100';
ALTER SYSTEM SET
 shared_buffers = '256MB';
ALTER SYSTEM SET
 effective_cache_size = '768MB';
ALTER SYSTEM SET
 maintenance_work_mem = '64MB';
ALTER SYSTEM SET
 checkpoint_completion_target = '0.9';
ALTER SYSTEM SET
 wal_buffers = '7864kB';
ALTER SYSTEM SET
 default_statistics_target = '100';
ALTER SYSTEM SET
 random_page_cost = '1.1';
ALTER SYSTEM SET
 effective_io_concurrency = '200';
ALTER SYSTEM SET
 work_mem = '655kB';
ALTER SYSTEM SET
 min_wal_size = '1GB';
ALTER SYSTEM SET
 max_wal_size = '4GB';
```
Sair do `prompt Postgres` com o comando `\q`:
```
\q
```
___

#### Ajuste de conexões

Gerar uma `senha de acesso` ao **postgres** e acessar o arquivo `pg_hba.conf` utilizando o programa `nano`:
>Lembrando de estar em modo sudo

Gerar a senha do usuário `postgres` com o seguinte comando:
```
password_postgres=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
```
>Exibir a senha do usuário postgres
```
echo "A senha do usuário postgres é $password_postgres"
```
Alterar para o diretório /:
```
cd /
```
Alterar a senha do usuário `postgres` para a senha gerada anteriormente
```
sudo -u postgres psql -c "alter user postgres with password '$password_postgres';"
```
Acessar a pasta `pg_hba.conf` através do programa `nano` utilizando o comando a seguir:
```
nano /etc/postgresql/15/main/pg_hba.conf 
```
>Com o arquivo aberto localizar a linha "Database administrative login by Unix domain socket" e comentar a linha utilizando o hashtag # no início da linha   
>Conforme o exemplo abaixo: 
>  
>#local all postgres peer  
>
>E localizar a linha abaixo da linha "Unix domain socket connections only" e alterar de modo pear para modo scram-sha-256   
>Conforme o exemplo abaixo:  
>  
>local all all scram-sha-256

>Finalizadas as alterações, executar o comando **Ctrl O** e **Enter** para salvar e **Ctrl X** para fechar. 

Após realizar a alteração de conexão necessário reiniciar o **postgres** utilizando o **systemctl restart**:
```
systemctl restart postgresql
```
Gerar a senha do usuário `mco` com o seguinte comando:
```
password_db=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
```
>Exibir a senha do usuário mco
```
echo "A senha do usuário mco é $password_db"
```
Criar a database `mco` o usuário `mco` e também utilize o comando abaixo para garantir todos os privilégios para o usuário `mco`:
```
echo -e "$password_postgres" | psql -U postgres -h 127.0.0.1 password=$password_postgres -c "CREATE DATABASE mco"
```
```
echo -e "$password_postgres" | psql -U postgres -h 127.0.0.1 password=$password_postgres -c "CREATE USER mco WITH PASSWORD '$password_db';"
```
```
echo -e "$password_postgres" | psql -U postgres -h 127.0.0.1 password=$password_postgres -c "GRANT ALL PRIVILEGES ON DATABASE mco TO mco;"
```
A partir de agora para acessar o **PostgreSQL** será necessário inserir a senha anteriormente gerada.  
Utilizar o comando abaixo e em seguida a insira a senha:
```
psql -U postgres -W
```
>Para acessar o usuário mco:
```
psql -U mco -W
```
Caso o acesso ao prompt do postgres ocorra, então as alterações foram um sucesso, caso contrário, refaça os passos acima.  
Sair do `prompt Postgres` com o comando `\q`:
```
\q
```
A instalação do PostgreSQL está completa!
___

Salvando o arquivo com as senhas:
```
echo "senha usuário postgres: $password_postgres" >> /home/marconsoft/senha.txt
```
```
echo "senha usuário mco: $password_db" >> /home/marconsoft/senha.txt
```


### Todas as ferramentas necessárias para a instalação do sistema MCO foram instaladas com sucesso!
