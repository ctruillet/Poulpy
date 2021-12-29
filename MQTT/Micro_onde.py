import paho.mqtt.client as mqtt
import random as rand
import time
from datetime import datetime

class Micro_onde:
    def __init__(self, id="", ip='127.0.0.255', port=1883, agregat = "BDE"):
        self.used = False
        self.nb_use = 0
        self.used_time = 0
        self.id = id
        self.agregat = agregat

        self.client = mqtt.Client(client_id="Micro_onde_"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()

    # Fonction pour mettre à jour l'état du micro-onde en fonction de l'heure de la journée
    def update_is_used(self):
        p = 0   # Probabilité de changer d'état (utilisé/libre).

        if self.used : # Lorsqu'il est utilisé les chances de changer d'état augmentent d'1%/s.
            p = self.used_time * 1
            self.used_time += 1
        else :
            # Les probabilité d'utilisation du micro-onde change en fonction de l'heure actuelle.
            now = datetime.now()
            if(now.hour >= 11 and now.minute <= 30 and now.hour < 14) :
                p = 90
            elif(now.hour >= 20 or now.hour <= 7) :
                p = 0
            else :
                p = 10

        # Tirage aléatoire pour le changement d'état
        switch = rand.uniform(0,100)
        if switch <= p :
            self.used = not self.used
            if self.used :
                self.used_time = 1
                self.nb_use += 1 # On augmente le nombre d'utilisation chaque fois que le micro-onde change d'état pour passer dans l'état utilisé.

    # Envoie le message MQTT du nombre d'utilisation du micro-onde
    def send_nb_use(self):
        self.client.publish("/" + self.agregat + "/micro_onde_" + self.id + "/number_use", str(self.nb_use))

    # Envoie le message MQTT indiquant si le micro-onde est utilisé ou non
    def send_is_used(self):
        self.client.publish("/" + self.agregat + "/micro_onde_" + self.id + "/is_used", str(self.used))

    # Action lorsque le micro-onde c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Micro-onde" + self.id + " connected !")

if __name__ == "__main__":
    micro_onde = Micro_onde()

    while(True) :
        micro_onde.update_is_used()
        micro_onde.send_is_used()
        micro_onde.send_nb_use()
        time.sleep(1)