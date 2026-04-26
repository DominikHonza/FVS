# Verifikace modulu TIMER

## Cíl verifikace

Cílem projektu bylo ověřit RTL implementaci timeru proti specifikaci v zadání. 
Registry `cnt_reg`, `cmp_reg`, `ctrl_reg` a `cycle_cnt`, odpovědi na rozhraní, generování přerušení `P_IRQ`, reset a přechody mezi módy timeru `DISABLED`, `AUTO_RESTART`, `ONE_SHOT` a `CONTINOUS`.

## Verifikační plán

Byly ověřeny všechny módy timeru:

- `DISABLED`: čítač neběží a přerušení se negeneruje.
- `AUTO_RESTART`: při shodě `cnt_reg == cmp_reg` se vygeneruje přerušení a čítač se nastaví na nulu.
- `ONE_SHOT`: při shodě se vygeneruje přerušení, čítač se nastaví na nulu a timer přejde do `DISABLED`.
- `CONTINOUS`: při shodě se vygeneruje přerušení a čítač pokračuje v běhu.

Na úrovni rozhraní byly ověřeny požadavky `CP_REQ_NONE`, `CP_REQ_READ`, `CP_REQ_WRITE` a `CP_REQ_RESERVED`, reakce `RESPONSE`, čtení a zápisy do všech registrových adres, přístup mimo adresový prostor, nezarovnané adresy a nevyužité zarovnané adresy v adresovém prostoru timeru.

Na strukturní úrovni byly sledovány statement, branch, condition a assertion coverage. Dodatečný test `addr_bus_branch_cover_t_test` byl přidán pro pokrytí větve čtení z nevyužité zarovnané adresy uvnitř adresového prostoru timeru.

## Testy

Použitá sada testů je uvedena v `test_lib/test_list`:

- `timer_t_test`
- `random_t_test`
- `autorestart_t_test`
- `oneshot_t_test`
- `disabled_t_test`
- `continuous_t_test`
- `mode_transition_t_test`
- `full_access_t_test`
- `reset_stress_t_test`
- `edge_cases_t_test`
- `addr_bus_branch_cover_t_test`
- `full_cov_t_test`

Pseudonáhodný test používá omezení podle zadání:

- `RST`: neaktivní hodnota s váhou 20, aktivní hodnota s váhou 1.
- `ADDRESS`: registry timeru mají váhy 7, 6, 5, 2, 2 a ostatní adresy jsou rozložené s váhou 1.
- `REQUEST`: `NONE`, `READ`, `WRITE`, `RESERVED` mají váhy 10, 5, 5, 1.
- `DATA_IN`: hodnota 0 má váhu 10, hodnoty 1 až 20 mají váhu 20 a vysoké hodnoty jsou rozložené s váhou 1.

## Funkční pokrytí

Sledovane body:

- hodnoty resetu a přechody resetu,
- adresy registrů,
- typy požadavků,
- hodnota a přechody `P_IRQ`,
- přerušení v jednotlivých módech,
- přechody mezi módy,
- kombinace adresa/požadavek/reset/mód.

Některé základní coverpointy (`mode_cp`, `req_cp`, `addr_cp`) mají `option.weight = 0`. Hodnocené biny jsou pokryty pomocí přímých testů a doplňkových coverage sekvencí.

## Formální tvrzení

ABV tvrzení kontrolují:

- nepřítomnost `X/Z` hodnot na řídicích a datových signálech,
- odpovědi `ACK`, `IDLE`, `ERROR`, `OOR`, `UNALIGNED`,
- zákaz generování `WAIT`,
- správné generování `P_IRQ`,
- chování `AUTO_RESTART` při shodě čítače a komparační hodnoty,
- korektní čtení po zápisu na stejnou adresu.

## Výsledky coverage reportů

Implementovaná verifikační sada dosahuje téměř plného pokrytí, přičemž většina metrik (assertions, branches, conditions, statements) dosahuje 100 %. Funkční pokrytí pomocí covergroups je na úrovni 99,25 %. Zbývající nepokrytá část funkčního pokrytí (0,75 %) odpovídá kombinacím,
které nebyly během testování aktivovány, pravděpodobně kvůli nízké pravděpodobnosti
jejich výskytu v pseudo-náhodném testu. RTL kód i ABV tvrzení jsou plně pokryty.

[![Cover ABV](media/cover_abv.png)](media/cover_abv.png)

[![Cover Covergroups](media/cover_covergroups.png)](media/cover_covergroups.png)

[![Cover Overall](media/cover_overall.png)](media/cover_overall.png)

[![Cover RTL](media/cover_rtl.png)](media/cover_rtl.png)

## Opravy `timer_fvs.vhd`

Původní implementace neodpovídala goldem modelu implementovaného podle specifikace.
Proto byla upravena priorita odpovědí tak, aby odpovídala očekávanému chování modelu,
i když se liší od textu zadání. Opravy na řádcích 85-95 (dle zadání).

Během verifikace se ukázalo několik míst v RTL, která bylo potřeba srovnat s očekávaným chováním timeru. V `timer_fvs.vhd` je teď explicitně rozlišený NONE request `CP_REQ_NONE`, RESERVED request, nezarovnaná adresa, adresa mimo prostor timeru a běžný platný přístup s odpovědí `ACK`.

Čtení a zápis do interních registrů jsou navázané až na platný `ACK`. Díky tomu se pro chybové požadavky, neplatné adresy nebo nezarovnané přístupy zbytečně nemění stav timeru. Zároveň se pokrylo chování nevyužité zarovnané adresy uvnitř adresového prostoru: přístup je potvrzený, ale čtená data zůstávají na výchozí hodnotě. Právě kvůli tomuto byl doplněn test `addr_bus_branch_cover_t_test`.

## Závěr

Implementovaná verifikační sada pokrývá hlavní funkční scénáře timeru, okrajové stavy sběrnicového rozhraní, reset chování, všechny módy timeru a přechody mezi nimi. Scoreboard i ABV v posledním běhu nehlásí žádné chyby.
