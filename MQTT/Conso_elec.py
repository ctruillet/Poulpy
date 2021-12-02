import paho.mqtt.client as mqtt
import random as rand
import time

class Conso_elec:
    def __init__(self, id="0", ip='127.0.0.255', port=1883, agregat = "BDE"):
        self.id = id
        self.agregat = agregat

        self.client = mqtt.Client(client_id="Conso_elec"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()    

    # Envoie le message MQTT de la consomation electrique
    def send_conso_elec(self, conso_add = 0):
        temp = rand.uniform(100,3000) + conso_add
        self.client.publish("/" + self.agregat + "/conso_elec" + self.id + "/consumption", temp)

    # Action lorsque le module de consomation electrique c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Conso_elec" + self.id + " connected !")

if __name__ == "__main__":
    df = Conso_elec()

    while(True) :
        df.send_conso_elec()
        time.sleep(1)