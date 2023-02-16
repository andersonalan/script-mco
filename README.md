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

Instale o pacote Postgres junto com <code>-contrib</code>
```
sudo apt install postgresql postgresql-contrib
```
A instalçaão criou uma conta de usuário chamada **postgres**
Para acessar o Postgres mudar para a conta **postgres** executando o seguinte comando:
```
sudo -i -u postgres
```
Então você consegue acessar o PostgreSQL prompt com o comando:
```
psql
```
Isso o coctará ao prompt do PostgreSQL.
Para sair utilizar executar o seguinte:
```
postgres=# \q
```
Isto te retornará para o **postgres**. Para retornar para o ubunutuserver utilize o comando <code>exit</code>:
```
postgres@ubuntuserver:~$ exit
```
Outro jeito de conectar com o PostgreSQL prompt é rodando o <code>psql</code> diretamente do terminal atravez do <code>sudo</code>:
```
sudo -u postgres psql
```
Para sair:
```
postgres=# \q
```


