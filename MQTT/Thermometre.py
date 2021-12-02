import paho.mqtt.client as mqtt
import random as rand
import time

class Thermometre:
    def __init__(self, id="0", ip='127.0.0.255', port=1883, agregat = "BDE"):
        self.id = id
        self.agregat = agregat

        self.client = mqtt.Client(client_id="Thermometre"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()    

    # Envoie le message MQTT de la temperature
    def send_temperature(self):
        temp = rand.uniform(10,30)
        self.client.publish("/" + self.agregat + "/thermometre" + self.id + "/temperature", temp)

    # Action lorsque le thermometre c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Thermometre_" + self.id + " connected !")

if __name__ == "__main__":
    df = Thermometre()

    while(True) :
        df.send_temperature()
        time.sleep(1)