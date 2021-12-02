import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

public class KillAPI  implements MqttCallback {
    //Attributs
    private static final String brokerUrl = "tcp://127.0.0.255:1883";
    private static final String clientId = "KILL API REST";

    //Constructeur
    public KillAPI() {
        MemoryPersistence persistence = new MemoryPersistence();
            try {
                MqttClient client = new MqttClient(brokerUrl, clientId, persistence);
                MqttConnectOptions connOpts = new MqttConnectOptions();
                connOpts.setCleanSession(true);

                client.connect(connOpts);

                client.publish("/api/kill", "".getBytes(), 0, false);
                client.disconnect();

            } catch (MqttException me) {
                System.err.println(me);
            }
    }

    //Méthodes
    @Override
    public void connectionLost(Throwable throwable) {

    }

    @Override
    public void messageArrived(String s, MqttMessage mqttMessage) throws Exception {

    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {

    }

    public static void main(String[] args) {
        new KillAPI();
    }
}
