# Prueba Proyecto - BD Distribuidas usando  mysql en VMs con Ubuntu Server 24 a una arquitectura MVC en C#

# 1. Creacion de las VMs
# Crear 3 VMs con Virtual Box.
# Las VMs deben tener la siguiente configuracion:
# - Nombre: Centro Medico Quito, Centro Medico Quito, Centro Medico Quito
# - Sistema Operativo: Ubuntu Server 24
# - Disco Duro: 35GB
# - Red: Adaptador Puente (Bridge Adapter)
# - IP: 10.79.3.X (donde X es el numero de la VM)
# - RAM: 2.5GB
# - Procesador: 2

# 2. Instalacion de Ubuntu Server 24 en las VMs

# - Seguir los pasos indicados en la instalacion de Ubuntu Server 24 y activar el SSH.
# - Al finalizar la instalacion, se debe reiniciar la VM y verificar que el SSH este activo en cada maquina.
# - Para verificar que el SSH este activo, se debe ejecutar el siguiente comando:
# ssh user@10.79.3.X (donde X es el numero de la VM, y user es el usuario creado en la instalacion de Ubuntu Server 24)

# 3. Instalacion de mysql en las VMs
# - Para instalar mysql en las VMs, se debe ejecutar ciertos comandos primero:
sudo apt update

# - Instalar mysql-server
sudo apt install mysql-server -y
sudo mysql_secure_installation

# - Iniciar el servicio de mysql
sudo systemctl start mysql

# - Verificar que el servicio de mysql este activo
sudo systemctl status mysql

# 4. Configurar la Red y el Firewall
sudo ufw allow from 10.79.3.0/24 to any port 3306  # Permitir conexiones desde la red local
sudo ufw allow 22  # Permitir conexiones SSH
sudo ufw enable  # Activar el firewall
sudo ufw status  # Verificar el estado del firewall 

sudo ufw reload  # Opcional - Reiniciar el firewall en caso de que se realicen cambios en la configuracion

# 5. Configuracion de los archivos para el servidor Master (Centro Medico Quito) y los servidores Esclavos (Centro Medico Guayaquil y Centro Medico Cuenca)

# - En el servidor Master (Centro Medico Quito), se debe editar el archivo de configuracion de mysql:
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf

# - En el servidor Esclavo (Centro Medico Guayaquil y Centro Medico Cuenca), se debe editar el archivo de configuracion de mysql:
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf






