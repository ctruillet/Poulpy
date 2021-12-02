import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class WebServer extends Thread implements MqttCallback{
    protected int port = 3000;
    protected JSONObject json = new JSONObject();
    protected JSONObject jsonTemp = new JSONObject();
    private boolean isAlive = true;
    private static final String brokerUrl = "tcp://127.0.0.255:1883";
    private static final String clientId = "API REST";
    private ServerSocket serverSocket;
    private ArrayList<String> topics = new ArrayList<>();

    public WebServer(int port) {
        super("WebServer");
        this.port = port;

        this.topics.add("BDE");
        this.topics.add("ADMIN");

        this.json.put("name", "API");
        this.json.put(
                "api", new JSONObject().put(
                        "BDE", new JSONObject().put(
                                "name", "BDE").put(
                                        "micro_onde_0", new JSONObject().put(
                                                "number_use", 9).put(
                                                        "is_used", true)
                        ).put(
                                "micro_onde_1", new JSONObject().put(
                                        "number_use", 8).put(
                                                "is_used", false)
                        ).put(
                                "conso_elec", 3211.67).put(
                                        "temperature", 29.27).put(
                                                "humidity", 0.0)
                )
        );
    }

    public void setJson(JSONObject json) {
        this.json = new JSONObject().put("name", "API").put("api", json);
    }

    public void start() {
        System.out.println("Starting WebServer on port " + port);

        try {
            this.serverSocket = new ServerSocket(port);
        } catch (IOException e) {
            e.printStackTrace();
        }

        this.subscribe(topics);

        // Thread MQTT
        new Thread(new Runnable() {

            @Override
            public void run() {
                while (true){
                    try {
                        Thread.sleep(1000 * 60 * 10);
                        setJson(jsonTemp);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();

        this.run();
    }

    private void addJSONValue(String key, String value){
        //key = key.substring(1);
        String[] keys = key.split("/");

        JSONObject json = this.jsonTemp;


        int i = 0;
        for (i = 0; i < keys.length - 1; i++){
            try{
                json = json.getJSONObject(keys[i]);
            }catch (JSONException e){
                json.put(keys[i], new JSONObject());
                json = json.getJSONObject(keys[i]);
            }
        }
        json.put(keys[i], value);
    }

    private void subscribe(ArrayList<String> topics) {
        MemoryPersistence persistence = new MemoryPersistence();

        try {
            MqttClient client = new MqttClient(brokerUrl, clientId, persistence);
            MqttConnectOptions connOpts = new MqttConnectOptions();
            connOpts.setCleanSession(true);

            System.out.println("checking");
            System.out.println("Mqtt Connecting to broker: " + brokerUrl);

            client.connect(connOpts);
            System.out.println("Mqtt Connected");

            client.setCallback(this);

            for (String topic : topics){
                client.subscribe(topic + "/#", 0);
            }
            client.subscribe("/api/kill", 0);

            //client.publish(topic, "Hello from MQTT".getBytes(), 0, false);

            System.out.println("Subscribed");
            System.out.println("Listening");

        } catch (MqttException me) {
            System.err.println(me);
        }
    }

    public void run() {
        while (this.isAlive) {
            try {
                Socket socket = serverSocket.accept();
                String request = new BufferedReader(new InputStreamReader(socket.getInputStream())).readLine();

                System.out.println("New client connected - " + request);


                ArrayList<String> requests = new ArrayList(List.of(request.substring("GET /".length(), request.length() - " HTTP/1.1".length()).split("/")));

                JSONObject jsonRequest = this.json;

                try {
                    for (String r : requests) {
                        if (r.equals(""))
                            continue;
                        jsonRequest = jsonRequest.getJSONObject(r);
                    }
                } catch (Exception e) {
                    System.out.println("Error : " + e.getMessage());
                    jsonRequest = new JSONObject();
                }

                PrintStream output = new PrintStream(socket.getOutputStream());

                String responce = "HTTP/1.1 200 OK\r\n"
                        + "Date: " + new Date() + "\r\n"
                        + "Content-Type: text/json\r\n"
                        + "Content-Length: " + jsonRequest.toString().length() + "\r\n\r\n";
                responce += jsonRequest.toString();
                responce += "\r\n\r\n";

                output.println(responce);
                System.out.println("REPLY\n" + responce + "\n============");
                output.flush();

                socket.close();

                Thread.sleep(1000);

            } catch (IOException ex) {
                System.out.println("Server exception: " + ex.getMessage());
                ex.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void connectionLost(Throwable throwable) {

    }

    @Override
    public void messageArrived(String topic, MqttMessage message) throws Exception {
        if (topic.equals("/api/kill")){
            System.exit(0);
        }else{
            this.addJSONValue(topic, new String(message.getPayload()));
        }
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {

    }
}