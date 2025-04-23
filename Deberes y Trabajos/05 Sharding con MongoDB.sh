# Practica sharding con MongoDB usando ubuntu server 22.

# Instalacion de MongoDB
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod

# Configuracion de MongoDB en modo sharding

# Editar el archivo de configuracion de MongoDB
sudo nano /etc/mongod.conf

# Cambiar la siguiente configuración en /etc/mongod.conf

sharding:
  clusterRole: "shardsvr"  # Define el rol del nodo como parte del shard

replication:
  replSetName: "rs0"  # Nombre del conjunto de réplicas

net:
  bindIp: 0.0.0.0  # Permitir conexiones desde cualquier IP (ajustar según seguridad)
  port: 27018      # Puerto para el nodo del shard (puede ser diferente al predeterminado)

security:
  keyFile: /etc/mongo/keyfile  # Archivo de clave para autenticación entre nodos

# Crear el archivo de clave para la autenticación entre nodos

openssl rand -base64 756 > /etc/mongo/keyfile
chmod 600 /etc/mongo/keyfile
chown mongodb:mongodb /etc/mongo/keyfile

# Reiniciar el servicio de MongoDB
sudo systemctl restart mongod
sudo systemctl status mongod

# Crear el conjunto de réplicas
# Iniciar el conjunto de réplicas
# Una vez configurado el archivo /etc/mongod.conf y reiniciado el servicio mongod, debes iniciar el conjunto de réplicas en cada nodo del shard.
# Ejecuta el siguiente comando en el shell de MongoDB para inicializar el conjunto de réplicas:

mongo --port 27018
rs.initiate()

# Configurar los servidores de configuración (Config Servers)
# Los servidores de configuración son necesarios para almacenar la metadata del clúster de sharding.
# Configura los nodos de configuración con el siguiente rol en /etc/mongod.conf:

sharding:
  clusterRole: "configsvr"  # Define el nodo como servidor de configuración

replication:
  replSetName: "configReplSet"  # Nombre del conjunto de réplicas para los config servers

net:
  bindIp: 0.0.0.0
  port: 27019  # Puerto para los config servers

# Crear el conjunto de réplicas para los servidores de configuración
# Inicia el shell de MongoDB en cada nodo de configuración y ejecuta:

mongo --port 27019
rs.initiate()

# Configurar el router (mongos)
# El router (mongos) es el componente que coordina las operaciones de sharding.
# Configura el archivo de configuración para mongos:

sharding:
  configDB: "configReplSet/host1:27019,host2:27019,host3:27019"  # Reemplaza con los hosts de tus config servers

  # Iniciar el servcicio Mongos
  mongos --config /etc/mongos.conf

# Agregar shards al clúster
# Conecta al router (mongos) y agrega los shards al clúster:

mongo --host <router-host> --port 27017
sh.addShard("rs0/host1:27018,host2:27018,host3:27018")  # Reemplaza con los hosts de tu shard

# Habilitar el sharding en una base de datos
# Una vez configurado el clúster, habilita el sharding para una base de datos específica:

sh.enableSharding("miBaseDeDatos")

# Crear una colección shardeada
# Define una clave shard para una colección y habilita el sharding:

sh.shardCollection("miBaseDeDatos.miColeccion", { campoShard: 1 })

#  Resumen de lo que sigue:
#  Configura los config servers.
#  Configura el router (mongos).
#  Agrega los shards al clúster.
#  Habilita el sharding en una base de datos y define las colecciones shard.

