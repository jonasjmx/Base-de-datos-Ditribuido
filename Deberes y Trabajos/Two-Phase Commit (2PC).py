# Two-Phase Commit (2PC)

# Guía Paso a Paso para Simular Two-Phase Commit (2PC) en Python
# Introducción
# El protocolo Two-Phase Commit (2PC) es un algoritmo de consenso distribuido que asegura que todas las partes en un sistema distribuido acuerden comprometer o abortar una transacción. Esta guía te mostrará cómo implementar una simulación simplificada en Python.
# 
# Paso 1: Diseño del Sistema
# Primero, definamos los componentes principales:
# 
# Coordinador: Maneja el proceso de 2PC y toma la decisión final
# 
# Participantes: Nodos que ejecutan partes de la transacción y votan
# 
# Paso 2: Configuración Inicial
# Crea un nuevo archivo Python (ej. 2pc_simulation.py) y define las clases básicas:

import random
import time
from enum import Enum

class Vote(Enum):
    COMMIT = 1
    ABORT = 2

class ParticipantStatus(Enum):
    READY = 1
    COMMITTED = 2
    ABORTED = 3
    
# Paso 3: Implementación del Participante


class Participant:
    def __init__(self, participant_id):
        self.id = participant_id
        self.status = ParticipantStatus.READY
        self.vote = None
        
    def prepare(self):
        # Simular posibilidad de fallo (10% de probabilidad de abortar)
        if random.random() < 0.1:
            self.vote = Vote.ABORT
        else:
            self.vote = Vote.COMMIT
        return self.vote
    
    def commit(self):
        if self.vote == Vote.COMMIT:
            self.status = ParticipantStatus.COMMITTED
            return True
        return False
    
    def abort(self):
        self.status = ParticipantStatus.ABORTED
        return True
    
    def __str__(self):
        return f"Participant {self.id}: {self.status.name}"
    
# Paso 4: Implementación del Coordinador


class Coordinator:
    def __init__(self, num_participants):
        self.participants = [Participant(i) for i in range(num_participants)]
        self.transaction_status = None
        
    def start_transaction(self):
        print("Fase 1: Fase de Preparación")
        votes = []
        
        # Paso 1: Solicitar votos de preparación
        for participant in self.participants:
            print(f"Solicitando voto a {participant.id}")
            vote = participant.prepare()
            votes.append(vote)
            print(f"Participante {participant.id} vota: {vote.name}")
            
        # Paso 2: Tomar decisión basada en votos
        print("\nEvaluando votos...")
        if all(v == Vote.COMMIT for v in votes):
            print("Todos votaron COMMIT - Procediendo con Fase 2: Commit")
            self.commit()
        else:
            print("Al menos un participante votó ABORT - Procediendo con Fase 2: Abort")
            self.abort()
            
    def commit(self):
        print("\nFase 2: Fase de Commit")
        for participant in self.participants:
            success = participant.commit()
            if success:
                print(f"Participante {participant.id} comprometido exitosamente")
            else:
                print(f"Error al comprometer participante {participant.id}")
        self.transaction_status = "COMMITTED"
        
    def abort(self):
        print("\nFase 2: Fase de Abort")
        for participant in self.participants:
            participant.abort()
            print(f"Participante {participant.id} abortado")
        self.transaction_status = "ABORTED"
        
    def print_status(self):
        print("\nEstado Final:")
        for participant in self.participants:
            print(participant)
        print(f"Estado de la transacción: {self.transaction_status}")
        
# Paso 5: Función Principal y Simulación

def main():
    print("Simulación de Two-Phase Commit (2PC)\n")
    
    # Configuración
    num_participants = 3
    coordinator = Coordinator(num_participants)
    
    # Ejecutar transacción
    coordinator.start_transaction()
    
    # Mostrar resultados
    coordinator.print_status()

if __name__ == "__main__":
    main()
    
# Paso 6: Ejecución y Pruebas
# Ejecuta el script: python 2pc_simulation.py
# 
# Observa los resultados. Debido a la aleatoriedad, verás diferentes resultados:
# 
# Todos COMMIT (transacción exitosa)
# 
# Al menos un ABORT (transacción fallida)
# 
# Paso 7: Mejoras Opcionales
# Puedes mejorar la simulación con:
# 
# Tiempos de espera: Simular fallos de red


def prepare(self):
    # Simular timeout (5% de probabilidad)
    if random.random() < 0.05:
        time.sleep(10)  # Causaría timeout
        return None
    # Resto de la lógica...
    
# Recuperación: Implementar logs y recuperación de fallos
# 
# Interfaz gráfica: Usar tkinter para visualización
# 
# Paso 8: Ejemplo de Salida
# 
# 
# Simulación de Two-Phase Commit (2PC)
# 
# Fase 1: Fase de Preparación
# Solicitando voto a 0
# Participante 0 vota: COMMIT
# Solicitando voto a 1
# Participante 1 vota: COMMIT
# Solicitando voto a 2
# Participante 2 vota: ABORT
# 
# Evaluando votos...
# Al menos un participante votó ABORT - Procediendo con Fase 2: Abort
# 
# Fase 2: Fase de Abort
# Participante 0 abortado
# Participante 1 abortado
# Participante 2 abortado
# 
# Estado Final:
# Participant 0: ABORTED
# Participant 1: ABORTED
# Participant 2: ABORTED
# Estado de la transacción: ABORTED
# 
# 
# Conclusión
# Esta simulación muestra los conceptos básicos de 2PC. En un entorno real, necesitarías manejar fallos de red, 
# persistencia y recuperación, pero este código proporciona una base para entender el protocolo.

