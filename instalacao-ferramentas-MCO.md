# Tutorial para instalação de Java 8 / Tomcat 9 / PostgreSQL

Tutorial básico para instalação das ferramentas necessárias para a instalação do sistema MCO no ambiente `Linux`

Após iniciar o ubuntuserver utilizar o comando `apt update` para atualizar a lista de pacotes
```
sudo apt updade
```
Em seguida atualizar os pacotes
```
sudo apt upgrade
```
___

## Primeiro passo - Instalando PostgreSQL

Instalar o Postgres junto com o pacote `-contrib`:
```
sudo apt install postgresql postgresql-contrib
```
Finalizada instalação uma conta de usuário é criada automaticamente com o nome **postgres**  
Para acessar o PostgreSQL mudar para a conta **postgres**, executando o seguinte comando:
```
sudo -i -u postgres
```
Para realizar conexão `PostgreSQL prompt` executar o seguinte comando:
```
psql
``` 
Para desconectar do `prompt do PostgreSQL` utilizar o comando `\q`:
```
postgres=# \q
```
O comando acima retornará para a conta **postgres**.   
Para retornar ao prompt do ubunutuserver, utilize o comando `exit`:
```
postgres@ubuntuserver:~$ exit
```
Outra forma de conexão com o `prompt PostgreSQL` é executar o comando `psql`, diretamente no terminal:
```
sudo -u postgres psql
```
Para desconectar do `prompt PostgreSQL`, executar o comando `\q`:
```
postgres=# \q
```
  
A seguir realizar o ajuste de memória e conexões dentro do arquivo `postgresql.conf` e no arquivo `pg_hba.conf`, respectivamente.

### Ajuste de memória e conexões PostgreSQL 

Para ajustar as configurações de memória e conexões do **postgres**, acessar a calculadora de configuração através do link: [PGTune](https://pgtune.leopard.in.ua/ "calculadora de ajuste de memória PostgreSQL"), inserindo os parâmetros da máquina.

> Inserindo os parâmetros da máquina, o site calculará os valores que serão alterados dentro do arquivo `postgresql.conf`.
>
> Como exemplo utilizei os parâmetros abaixo, extraindo a partir da VM do ubuntuserver.

Parameters of your system
- DB version 14
- OS Type Linux
- DB Type Mixed type of application
- Total Memory (RAM) 2GB
- Number of CPUs 2
- Number of Connections 100
- Data Storage SSD storage

Clicando no botão `Generate` a calculadora irá mostrar os parâmetros a serem utilizados ao lado direito.
O passo seguinte é ir até o arquivo `postgresql.conf` que fica no caminho `/etc/postgresql/14/main/postgresql.conf` e através do programa `nano` realizar a alteração dos parâmetros.

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

>lembrando de estar em usuário root



Para editar o arquivo `postgresql.conf` acessar a pasta `/main` localizada dentro do caminho de instalação do postgres:

```
cd /etc/postgresql//main/
```
Após acessar a pasta `./main`, executar o programa `nano` no arquivo `postgresql.conf`, para edição dos parâmetros:
```
nano postgresql.conf
```
>Com o aquivo `postgres.conf` aberto utilize o **Ctrl W** para localizar os parâmetros.

>Caso o parâmetro esteja comentado com hashtag `#` remover a hashtag `#`.

>Finalizada as alterações, executar o comando **Ctrl O** para salvar e **Ctrl X** para fechar.

Para validar alterações realizadas, acesse o terminal e execute o comando abaixo.

```
sudo -u postgres psql
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
Instalar o Java Runtime Enviroment (JRE), através do comando a seguir:
```
sudo apt install openjdk-8-jre-headless 
```
Instalar o Java Development Kit (JDK), através do comando a seguir:
```
sudo apt install openjdk-8-jdk-headless
```
Para confirmar a instalação executar os comandos `java -version` e `javac -version`.

A instalação do Java 8 está completa!

___

## Terceiro passo - Instalando Tomcat 9

Antes de iniciar a instalação atualize o gerenciador de pacotes com o comando:
```
sudo apt updade
```
Para instalação do `tomcat`, necessário baixar o instalador compactado `.tar.gz` e criar um diretório.

Para criar o diretório executar os comandos a seguir:
```
sudo su
```
```
cd /
```
```
mkdir -p applications/installers
```
```
cd applications/installers/
```
Antes de iniciar a instalação do tomcat necessário liberar a permisão de usuário para a pasta `applications` através do comando `chmod`:
```
sudo chmod -R 777 /applications
```
O instalador `.tar.gz` será baixado através do comando `wget` junto com o link do download:

>Lembrando que precisa estar na pasta `/applications/installers` para baixar o instalador.

```
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
```
Para extrair o tomcat na pasta, executar o comando:
```
sudo tar -xvzf apache-tomcat-9.0.21.tar.gz
```
O próximo passo é criar o arquivo `tomcat.service` para a inicialização do `systemctl` e para fazer ir isso ir até a pasta `system` dentro do `etc` através dos seguintes comandos:
```
cd /etc/systemd/system
```
Agora precisa criar o arquivo utilizando o `nano`:
```
nano tomcat.service
```
Abaixo segue o modelo do arquivo:
>Lembrando que caso o path das variáveis de ambiente esteja diferente precisa alterar o path no arquivo.

```
[Unit]
Description=Apache Tomcat Web Application Container
Wants=network.target
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/

Environment=CATALINA_PID=/applications/installers/apache-tomcat-9.0.21/temp/tomcat.pid  
Environment=CATALINA_HOME=/applications/installers/apache-tomcat-9.0.21/
Environment='CATALINA_OPTS=-Xms512M -Xmx1G -Djava.net.preferIPv4Stack=true'
Environment='JAVA_OPTS=-Djava.awt.headless=true'

ExecStart=/applications/installers/apache-tomcat-9.0.21/bin/startup.sh
ExecStop=/applications/installers/apache-tomcat-9.0.21/bin/shutdown.sh
SuccessExitStatus=143

RestartSec=10
Restart=always
 
[Install]
WantedBy=multi-user.target
```
>Finalizando o arquivo **Ctrl O** para salvar e **Ctrl X** para fechar.

Agora precisa utilizar o `systemctl` para habilitar o serviço de inicialização com o comando `enable` e depois iniciar com o comando `start`. 

Para habilitar utilize primeiro o comando `enable`:

```
systemctl enable tomcat.service
```
Depois de habilitado utilize o comando `start` para iniciar:
```
systemctl start tomcat.service
```

Para verificar o status do serviço utilize o comando `status`:
```
systemctl status tomcat.service
```
 
Tomcat instalado e serviço de inicialização feito com sucesso!  

Todas as ferramentas necessárias para a instalação do sistema MCO foram instaladas com sucesso!




