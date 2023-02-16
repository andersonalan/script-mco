# Tutorial para instalação de Java 8 / Tomcat 9 / PostgreSQL

Tutorial básico para instalação das ferramentas necessárias para

Iniciando o Ubuntuserver via ssh atualizar a lista de pacotes
```
sudo apt updade
```
E depois atualizar os pacotes
```
sudo apt upgrade
```
## Primeiro passo - Instalando PostgreSQL

Instale o pacote Postgres junto com `-contrib`:
```
sudo apt install postgresql postgresql-contrib
```
A instalação criou uma conta de usuário chamada **postgres**
Para acessar o Postgres mudar para a conta **postgres** executando o seguinte comando:
```
sudo -i -u postgres
```
Então você consegue acessar o PostgreSQL prompt com o comando:
```
psql
```
Isso o coctará ao prompt do PostgreSQL.
Para sair utilizar executar o `\q`:
```
postgres=# \q
```
Isto te retornará para o **postgres**. Para retornar para o ubunutuserver utilize o comando `exit`:
```
postgres@ubuntuserver:~$ exit
```
Outro jeito de conectar com o PostgreSQL prompt é rodando o `psql` diretamente do terminal atravez do `sudo`:
```
sudo -u postgres psql
```
Para sair:
```
postgres=# \q
```
A instalação do PostgreSQL está completa! 
Os próximos passos serão o ajuste de memória e conexões dentro do arquivo `postgresql.conf` e no arquivo `pg_hba.conf`.

### Ajuste de memória e conexões PostgreSQL 

Para ajustar as as configurações de memória e conexões do **postgres** ir até o site [PGTune](https://pgtune.leopard.in.ua/ "calculadora de ajuste de memória PostgreSQL") 

> Inserindo os parâmetros da maquina virtual o site calculará os valores que serão alterados dentro do arquivo `postgresql.conf`.
>
> Como exemplo utilizei os parâmetros abaixo extraindo a partir da VM de ubuntuserver.

Parameters of your system
- DB version 14
- OS Type Linux
- DB Type Mixed type of application
- Total Memory (RAM) 2GB
- Number of CPUs 2
- Number of Connections 100
- Data Storage SSD storage

Clicando no botão `Generate` vai mostrar os parâmetros corretos ao lado direito.
O próximo passo é ir até o arquivo que fica no caminho `/etc/postgresql/14/main/postgresql.conf` e atravez do `nano` e fazer a alteração.

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

Ir até a pasta `/main`:
```
cd /etc/postgresql/14/main/
```
E executar o `nano` para editar os parâmetros:
```
nano postgresql.conf
```
>Utilize o **Ctrl W** para procurar os parâmetros.

>Caso o parâmetro esteja comentado com hashtag `#` remover a hashtag `#`.

>Finalizando as alterações **Ctrl O** para salvar e **Ctrl X** para fechar.

Para verificar alterações realize o comando abaixo acessando o prompt do Postgres.

```
sudo -u postgres psql
```
Se realizar o acesso no prompt as alterações foram um sucesso!


## Segundo passo - Instalando Java 8

Atualize o gerenciador de pacotes com o comando:
```
sudo apt updade
```
Execute o seguinte comando para instalar o Java Runtime Enviroment (JRE):
```
sudo apt install openjdk-8-jre-headless 
```
Então instalar o Java Development Kit (JDK):
```
sudo apt install openjdk-8-jdk-headless
```
Para confirmar a instalação basta executar `java -version` e `javac -version`.

A instalação do Java 8 está completa!
O próximo passo é instalar o Tomcat 9.

## Terceiro passo - Instalando Tomcat 9 

Para instalar o tomcat precisa primeiramente criar um diretório para fazer isso seguir os passos abaixo:
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
Agora para instalar o tomcat 9 precisa dar a permisão para a pasta applications através do comando `chmod`:
```
sudo chmod -R 777 /applications
```
Baixar o arquivo `tar.gz` através do comando `wget` e o link do download:

>Lembrando que precisa estar na pasta `/applications/installers` para baixar o arquivo.

```
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
```
Para extrair:
```
sudo tar -xvzf apache-tomcat-9.0.21.tar.gz
```



