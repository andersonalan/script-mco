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

/etc/postgresql/14/main

Para ajustar as as configurações de memória e conexões do **postgres** ir até o site [PGTune](https://pgtune.leopard.in.ua/ "calculadora de ajuste de memória PostgreSQL") 

> Inserindo os parâmetros da maquina virtual o site calculará os valores que serão alterados dentro do arquivo `postgresql.conf`.
>
> Segue o exemplo de parâmetros abaixo tirados a partir da VM de ubuntuserver.

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










