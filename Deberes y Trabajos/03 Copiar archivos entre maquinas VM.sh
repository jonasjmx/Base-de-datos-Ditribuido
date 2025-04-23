# Comunicación y envio de datos (archivo) a travez de scp entre ubuntu server 24(máquina virtual) y windows (maquina fisica).

# 1. Instalar OpenSSH en la máquina virtual de Ubuntu Server 22
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
# 2. Instalar OpenSSH en la máquina física de Windows 11 (ya instalado por defecto)
# 3. Configurar el firewall de Windows para permitir conexiones SSH
# 4. Obtener la dirección IP de la máquina virtual de Ubuntu Server 22
ip addr show
# 5. Probar la conexión SSH desde la máquina física de Windows 11
ssh usuario@ip_ubuntu_server
# 6. Copiar un archivo desde la máquina física de Windows 11 a la máquina virtual de Ubuntu Server 22
scp C:\ruta\del\archivo usuario@ip_ubuntu_server:/ruta/destino
# 7. Copiar un archivo desde la máquina virtual de Ubuntu Server 22 a la máquina física de Windows 11
scp usuario@ip_ubuntu_server:/ruta/del/archivo C:\ruta\destino

