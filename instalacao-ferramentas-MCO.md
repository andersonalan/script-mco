# Tutorial para instalação de Java 8 / Tomcat 9 / PostgreSQL

Tutorial básico para instalação das ferramentas necessárias para a instalação do sistema MCO no ambiente `Linux`

Iniciar o ubuntuserver e executar o comando `apt update` para atualizar a lista de pacotes
```
sudo apt updade
```
Em seguida atualizar os pacotes
```
sudo apt upgrade
```
___

## Primeiro passo - Instalando PostgreSQL

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

> Inserindo os parâmetros da máquina, o site calculará os valores que serão alterados dentro do arquivo `postgresql.conf`.
>
> Como exemplo utilizei os parâmetros abaixo, extraindo a partir da VM do ubuntuserver.

Parameters of your system
- DB version 15
- OS Type Linux
- DB Type Mixed type of application
- Total Memory (RAM) 2GB
- Number of CPUs 2
- Number of Connections 100
- Data Storage SSD storage

Clicando no botão `Generate` a calculadora irá mostrar os parâmetros ao lado direito a serem utilizados.
A seguir abrir arquivo `postgresql.conf` localizado em `/etc/postgresql/15/main/postgresql.conf` e através do programa `nano` realizar a alteração dos parâmetros com o comando:

>lembrando de estar em usuário root

```
nano /etc/postgresql/15/main/postgresql.conf
```
> Abaixo o resultado do exemplo:

- max_connections = 100
- shared_buffers = 512MB
- effective_cache_size = 1536MB
- maintenance_work_mem = 128MB
- checkpoint_completion_target = 0.9
- wal_buffers = 16MB
- default_statistics_target = 100
- random_page_cost = 4
- effective_io_concurrency = 2
- work_mem = 1310kB
- min_wal_size = 1GB
- max_wal_size = 4GB

>Com o aquivo `postgres.conf` aberto utilize o **Ctrl W** para localizar os parâmetros.  
>Caso o parâmetro esteja comentado com hashtag `#` remover a hashtag `#`.  
>Finalizadas as alterações, executar o comando **Ctrl O** para salvar e **Ctrl X** para fechar.  
___

#### Ajuste de conexões

Criar uma `senha de acesso` ao **postgres** e acessar o arquivo `pg_hba.conf` utilizando o programa `nano`:

Acessar o `prompt Postgres` com o comando abaixo.
```
sudo -u postgres psql
```
Dentro do `terminal Postgres` criar a senha do usuário **postgres** com o seguinte comando:

```
alter user postgres with password 'senha desejada';
```
Sair do `prompt Postgres` com o comando `\q`:
```
\q
```
Acessar a pasta `pg_hba.conf` através do `nano` utilizando o comando a seguir:
```
nano /etc/postgresql/15/main/pg_hba.conf 
```
> Comentar a linha abaixo da Database administrative login by Unix domain socket.  
> Para comentar a linha apenas adicionar o hashtag anterior no início da linha conforme o exemplo abaixo:  
>#local all all peer

Após feito a alteração reiniciar o **postgres** utilizando o **systemctl restart**:
```
systemctl restart postgres
```
A partir de agora para acessar o **PostigreSQL** será nessário inserir a senha anteriormente criada.  
Para isso utilize o comando abaixo e depois a inserir a senha:
```
psql -U postgres --password
```
Caso o acesso ao prompt do postgres ocorra, as alterações foram um sucesso!  
Caso contrário refaça os passos acima.  

A instalação do PostgreSQL está completa!
___

## Segundo passo - Instalando Java 8

Antes de iniciar a instalação atualize o gerenciador de pacotes com o comando:
```
sudo apt updade
```
Instalar o Java Development Kit (JDK), através do comando a seguir:
```
sudo apt install openjdk-8-jdk-headless
```
Para confirmar a instalação executar os comandos `java -version` e `javac -version`.

A instalação do Java 8 está completa!

___

## Terceiro passo - Instalando Tomcat 9

Antes de iniciar a instalação atualizar o gerenciador de pacotes com o comando:
```
sudo apt updade
```
Criar o diretório de instalação do tomcat através dos comandos a seguir.
```
sudo mkdir -p /applications/installers
```
```
sudo cd /applications/installers/
```
Baixar o instalador `.tar.gz` através do comando `wget` junto ao link do download:

>Lembrando que precisa estar na pasta `/applications/installers` para baixar o instalador.

```
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
```
Extrair o tomcat no diretório criado e executar o comando:
```
sudo tar -xvzf apache-tomcat-9.0.21.tar.gz
```
Alterar o nome do arquivo:
>Como exemplo utilizei o nome tomcat
```
sudo mv -r /applications/installers/apache-tomcat-9.0.21 /applications/installers/tomcat 
```
Criar o arquivo `tomcat.service` necessário para a inicialização do gerenciador de serviços `systemctl` dentro da pasta `/etc/systemd/system` através do seguinte comando:

```
sudo nano /etc/systemd/system/tomcat.service
```
Para saber o caminho do `java 8` utilize o comando a seguir:
```
sudo update-alternatives --config java
```
Abaixo segue o modelo do arquivo:
>Lembrando que caso o caminho das variáveis de ambiente esteja diferente precisa alterar o caminho no arquivo.
```
[Unit]
Description=Apache Tomcat Web Application Container
Wants=network.target
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/

Environment=CATALINA_PID=/applications/installers/tomcat/temp/tomcat.pid  
Environment=CATALINA_HOME=/applications/installers/tomcat/
Environment='CATALINA_OPTS=-Xms512M -Xmx1G -Djava.net.preferIPv4Stack=true'
Environment='JAVA_OPTS=-Djava.awt.headless=true'

ExecStart=/applications/installers/tomcat/bin/startup.sh
ExecStop=/applications/installers/tomcat/bin/shutdown.sh
SuccessExitStatus=143

RestartSec=10
Restart=always
 
[Install]
WantedBy=multi-user.target
```
>Finalizando o arquivo **Ctrl O** para salvar e **Ctrl X** para fechar.

Agora precisa utilizar o `systemctl` para habilitar o serviço de inicialização com o comando `enable` e depois iniciar com o comando `start`. 
```
systemctl daemon-reload
```
Para habilitar utilize primeiro o comando `enable`:
```
systemctl enable tomcat
```
Depois de habilitado utilize o comando `start` para iniciar:
```
systemctl start tomcat
```
Para verificar o status do serviço utilize o comando `status`:
```
systemctl status tomcat
```
Tomcat instalado e serviço de inicialização feito com sucesso!  

Todas as ferramentas necessárias para a instalação do sistema MCO foram instaladas com sucesso!
