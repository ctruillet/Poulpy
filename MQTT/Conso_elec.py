import paho.mqtt.client as mqtt
import random as rand
import time

class Conso_elec:
    def __init__(self, id="", ip='localhost', port=1883, agregat = "BDE"):
        self.id = id
        self.agregat = agregat
        self.conso = rand.uniform(800,3000)

        self.client = mqtt.Client(client_id="Conso_elec"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()    

    # Envoie le message MQTT de la consomation electrique
    def send_conso_elec(self, conso_add = 0):
        c = rand.uniform(-100,100) + conso_add + self.conso
        if c > 3500:
            self.conso = 3500
        elif c < 100:
            self.conso = 100
        else:
            self.conso = c
        self.client.publish("/" + self.agregat + "/conso_elec" + self.id + "/consumption", self.conso)

    # Action lorsque le module de consomation electrique c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Conso_elec" + self.id + " connected !")

if __name__ == "__main__":
    df = Conso_elec()

    while(True) :
        df.send_conso_elec()
        time.sleep(1)