import paho.mqtt.client as mqtt
import random as rand
import time

class Compteur_personne:
    def __init__(self, id="", ip='localhost', port=1883, agregat = "Admin", room = "SRI"):
        self.id = id
        self.agregat = agregat
        self.prob_new_nb = 10
        self.nb_p = rand.uniform(0,5)
        self.room = room

        self.client = mqtt.Client(client_id="Compteur_personne"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()    

    # Envoie le message MQTT de comptage de personne
    def send_nb_person(self, conso_add = 0):
        x = rand.uniform(0,100)
        if x < self.prob_new_nb:
            self.nb_p = rand.randint(0,5)
        self.client.publish("/" + self.agregat + "/" + self.room + "/nb_person", self.nb_p)

    # Action lorsque le module de comptage de personne c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Compteur_personne" + self.id + " connected !")

if __name__ == "__main__":
    p = Compteur_personne()

    while(True) :
        p.send_nb_person()
        time.sleep(1)