import paho.mqtt.client as mqtt
import random as rand
import time
from datetime import datetime

class Detecteur_fumee:
    def __init__(self, id='', ip='localhost', port=1883, agregat = "BDE"):
        self.smoke = False
        self.smoke_time = 0
        self.id = id
        self.agregat = agregat

        self.client = mqtt.Client(client_id="Detecteur_fumee"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()

    # Fonction pour mettre à jour l'état
    def update_is_smoke(self):
        p = 1   # Probabilité de changer d'état (1% de chance de passer dans l'etat detection de fumée).

        if self.smoke : # Lorsqu'il y a de la fumée les chances de changer d'état augmentent d'0.1%/s.
            p = self.smoke_time * 1
            self.smoke_time += 1

        # Tirage aléatoire pour le changement d'état
        switch = rand.uniform(0,100)
        if switch <= p :
            self.smoke = not self.smoke
            if self.smoke:
                self.somke_time = 1
    

    # Envoie le message MQTT de si on detecte de la fumée ou non
    def send_is_smoke(self):
        self.client.publish("/" + self.agregat + "/detecteur_fumee" + self.id + "/smoke", str(self.smoke))

    # Action lorsque le détecteur de fumée c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Detecteur_fumee_" + self.id + " connected !")

if __name__ == "__main__":
    df = Detecteur_fumee()

    while(True) :
        df.update_is_smoke()
        df.send_is_smoke()
        time.sleep(1)