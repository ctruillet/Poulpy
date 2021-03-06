import time
from Conso_elec import Conso_elec
from Detecteur_fumee import Detecteur_fumee
from Micro_onde import Micro_onde

conso_elec = Conso_elec(ip="127.0.0.255")

micro_onde0 = Micro_onde(ip="127.0.0.255", id="0")
micro_onde1 = Micro_onde(ip="127.0.0.255", id="1")

detecteur_fumee = Detecteur_fumee(ip="127.0.0.255", )

while True :
    micro_onde0.update_is_used()
    micro_onde0.send_is_used()
    micro_onde0.send_nb_use()

    micro_onde1.update_is_used()
    micro_onde1.send_is_used()
    micro_onde1.send_nb_use()

    detecteur_fumee.send_is_smoke()

    conso_micro_onde = 300 * micro_onde0.used + 500 * micro_onde1.used
    conso_elec.send_conso_elec(conso_add=conso_micro_onde)

    time.sleep(1)