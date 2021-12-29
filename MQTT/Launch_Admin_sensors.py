import time
from Conso_elec import Conso_elec
from Detecteur_fumee import Detecteur_fumee
from Compteur_personne import Compteur_personne
from Thermometre import Thermometre


Compteur_personne0 = Compteur_personne(ip="127.0.0.255", id="0", room="SRI")
Compteur_personne1 = Compteur_personne(ip="127.0.0.255", id="1", room="GCGEO")
Compteur_personne2 = Compteur_personne(ip="127.0.0.255", id="2", room="STRI")
Compteur_personne3 = Compteur_personne(ip="127.0.0.255", id="3", room="Direction")

thermometre = Thermometre(ip="127.0.0.255", agregat="Admin")

conso_elec = Conso_elec(ip="127.0.0.255", agregat="Admin")

detecteur_fumee = Detecteur_fumee(ip="127.0.0.255", agregat="Admin")

while True :
    Compteur_personne0.send_nb_person()
    Compteur_personne1.send_nb_person()
    Compteur_personne2.send_nb_person()
    Compteur_personne3.send_nb_person()

    thermometre.send_temperature()

    conso_elec.send_conso_elec()

    detecteur_fumee.send_is_smoke()

    time.sleep(1)