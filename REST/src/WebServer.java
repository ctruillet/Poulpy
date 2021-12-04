import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/*
     WebServer
     Classe gerant la liaison entre le broker MQTT et l'API REST

     Le serveur web est un serveur TCP (http://localhost:<port>/) qui attend une requete HTTP
     et la reponse est un fichier HTML
     Par défault, le port est 3000

     Le serveur MQTT est un serveur MQTT qui envoie des messages
     avec des informations sur les capteurs

     Une mise à jour du fichier json est effectuée toutes les 10 minutes.
     Ce json est stocké dans le fichier data.json.

 */

public class WebServer extends Thread implements MqttCallback{
    protected int port;
    protected JSONObject json = new JSONObject();
    protected JSONObject jsonTemp = new JSONObject();

    private boolean isAlive = true;
    private ServerSocket serverSocket;

    private final ArrayList<String> topics = new ArrayList<>();

    private static String brokerUrl = "";
    private static String APIkeyWeatherMap = "";

    private static final String clientId = "API REST";


    /**
    Constructeur de la classe WebServer
     */
    public WebServer() {
        super("WebServer");

        // Récupération des parametres sur server
        this.getConfidentialKeys();


        this.topics.add("BDE");
        this.topics.add("ADMIN");

        this.json.put("name", "API");
        this.json = this.getJSONFromFile("data.json");
    }

    // Méthodes

    /**
    Méthode permettant de mettre à jour le fichier json et de le sauvegarder
     * @param json
     */
    public void setJson(JSONObject json) {
        this.json = new JSONObject().
                put("name", "API").
                put("api", json);
        this.saveJSONToFile(json, "data.json");
    }

    /**
     *
     */
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
                        Thread.sleep(10 * 60 * 1000);
                        System.out.println("Thread MQTT wakes up");

                        // Récupération de la météo via l'API WeatherMap à Rangueil
                        jsonTemp.put("weather",getAPIWeatherMap("Rangueil"));
                        setJson(jsonTemp);

                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }finally {
                        System.out.println("Thread MQTT goes to sleep");
                    }
                }
            }

            /**
             *
             * @param city
             * @return
             */
            private JSONObject getAPIWeatherMap(String city){
                //TODO: API WeatherMap
                try {
                    JSONObject jsonWeatherMap;

                    String url = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&APPID=" + APIkeyWeatherMap;
                    URL obj = new URL(url);

                    BufferedReader in = new BufferedReader(new InputStreamReader(obj.openStream()));
                    String inputLine;
                    StringBuffer response = new StringBuffer();

                    while ((inputLine = in.readLine()) != null) {
                        response.append(inputLine);

                    }
                    in.close();

                    JSONObject jsonReceive = new JSONObject(response.toString());

                    jsonWeatherMap = new JSONObject().
                            put("temperature", Double.
                                    parseDouble(new DecimalFormat("###.##").
                                    format(jsonReceive.
                                            getJSONObject("main").
                                            getDouble("temp") - 273.15).
                                    replace(',','.')
                                    )
                            ).
                            put("humidity", jsonReceive.
                                    getJSONObject("main").
                                    getDouble("humidity")
                            ).
                            put("pressure", jsonReceive.
                                    getJSONObject("main").
                                    getDouble("pressure")
                            );

                    return jsonWeatherMap;

                } catch (IOException e) {
                    e.printStackTrace();
                    return  null;
                }

            }
        }).start();

        this.run();
    }

    /**
     *
     * @param key
     * @param value
     */
    private void addJSONValue(String key, String value){
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

    /**
     *
     * @param topics
     */
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

    /**
     *
     */
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
                System.out.println("Responce sent");
                //System.out.println("REPLY\n" + responce + "\n============");
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

    /**
     *
     * @param throwable
     */
    @Override
    public void connectionLost(Throwable throwable) {

    }

    /**
     *
     * @param topic
     * @param message
     * @throws Exception
     */
    @Override
    public void messageArrived(String topic, MqttMessage message) throws Exception {
        if (topic.equals("/api/kill")){
            this.isAlive = false;
            System.exit(0);
        }else{
            this.addJSONValue(topic, new String(message.getPayload()));
        }
    }

    /**
     *
     * @param iMqttDeliveryToken
     */
    @Override
    public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {

    }

    /**
     *
     */
    private void getConfidentialKeys() {
        try {
            FileReader reader = new FileReader("confidential.json");
            JSONObject json = new JSONObject(new JSONTokener(reader));

            APIkeyWeatherMap = String.valueOf(json.getString("apiKeyWeatherMap"));
            brokerUrl = json.getString("brokerURL") + ":" + json.getString("brokerPort");
            this.port = json.getInt("port");

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     *
     * @param fileName
     * @return
     */
    private JSONObject getJSONFromFile(String fileName) {
        try {
            FileReader reader = new FileReader(fileName);
            JSONObject json = new JSONObject(new JSONTokener(reader));
            return json;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     *
     * @param json
     * @param fileName
     */
    private void saveJSONToFile(JSONObject json, String fileName) {
        try {
            FileWriter writer = new FileWriter(fileName);
            writer.write(json.toString());
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}