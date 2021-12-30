# Projet Interaction Distribuee
3A SRI - UPSSITECH

*Alexandre Malgouyres
Anaïs Mondin
Julie Pivin-Bachler
Clément Truillet*


Vidéo de démonstration : [https://www.youtube.com/watch?v=vEdVBKWqiRc](https://www.youtube.com/watch?v=vEdVBKWqiRc)


# Prérequis
Aavnt tout lancement, veuillez a bien ajouter ces fichiers ci-dessous completés dans les bons dossiers.

**ssid.json** (*Arduino/Temperature*)
```json
{
    "SSID" : "<SSIS>",
    "PASSWORD" : "<PASSWORD>"
}
```

**confidential.json** (*REST*)
```json
{
  "brokerURL" : "tcp://127.0.0.255",
  "brokerPort" : "1883",
  "port" : 3000,
  "apiKeyWeatherMap" : "<API_KEY_WEATHERMAP>"
}
```

## Lancement
Afin d'utiliser l'application, veuillez à bien lancer le broker MQTT (Disponible au téléchargement ici : [https://www.shiftr.io/](https://www.shiftr.io/))   
Après avoir lancé les capteurs virtuels (dossier *MQTT*) et le capteur physique (*Arduino/Temperature*), l'API REST peut être lancée en executant *API REST.jar* (dossier REST).
Votre API est maintenant disponible à l'adresse [http://localhost:3000/api](http://localhost:3000/api).

Pour acceder au dashboard, il suffit de lancer l'executable *Dashboard.exe* présent dans le dossier *Dashboard/application.windows64*.
