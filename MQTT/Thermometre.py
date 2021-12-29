import paho.mqtt.client as mqtt
import random as rand
import time

class Thermometre:
    def __init__(self, id="", ip='localhost', port=1883, agregat = "BDE"):
        self.id = id
        self.agregat = agregat
        self.temp = rand.uniform(15,25)

        self.client = mqtt.Client(client_id="Thermometre"+id)
        self.client.on_connect = self.on_connect
        self.client.connect(ip, port=port)
        self.client.loop_start()    

    # Envoie le message MQTT de la temperature
    def send_temperature(self):
        t = rand.uniform(-1,1) + self.temp
        if t < 10:
            self.temp = 10
        elif t > 30:
            self.temp = 30
        else:
            self.temp = t
        self.temp = round(self.temp,2)

        self.client.publish("/" + self.agregat + "/thermometre" + self.id + "/temperature", self.temp)

    # Action lorsque le thermometre c'est bien connecté au réseau MQTT
    def on_connect(self, client, userdata, flag, rc):
        print("Thermometre_" + self.id + " connected !")

if __name__ == "__main__":
    df = Thermometre()

    while(True) :
        df.send_temperature()
        time.sleep(1)