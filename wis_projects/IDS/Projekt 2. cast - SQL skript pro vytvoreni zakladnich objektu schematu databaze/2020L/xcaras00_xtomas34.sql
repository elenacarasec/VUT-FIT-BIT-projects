DROP TABLE zamestnanec_kavarna;
DROP TABLE uzivatel_kavarna;
DROP TABLE majitel_kavarna;
DROP TABLE druh_kavy_cupping_akce;
DROP TABLE druh_kavy_druh_kavoveho_zrna;
DROP TABLE druh_kavoveho_zrna;
DROP TABLE reakce;
DROP TABLE recenze;
DROP TABLE cupping_akce;
DROP TABLE provozni_doba;
DROP TABLE kavarna;
DROP TABLE uzivatel;
DROP TABLE druh_kavy;
DROP TABLE majitel;

DROP TABLE zamestnanec;


CREATE TABLE zamestnanec(
    id_zamestnance NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    jmeno VARCHAR(100) NOT NULL,
    prijmeni VARCHAR(100) NOT NULL,
    pracovni_pozice VARCHAR(100) NOT NULL
);
 CREATE TABLE majitel(
    id_zamestnance NUMBER UNIQUE NOT NULL,
    FOREIGN KEY (id_zamestnance) REFERENCES zamestnanec(id_zamestnance)
);
CREATE TABLE druh_kavy(
    id_kavy NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    oblast_puvodu VARCHAR(50) NOT NULL,
    kvalita VARCHAR(50) NOT NULL,
    chut VARCHAR(50) NOT NULL
);
CREATE TABLE uzivatel(
    id_uzivatele NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    jmeno VARCHAR(100) NOT NULL,
    prijmeni VARCHAR(100) NOT NULL,
    datum_narozeni DATE NOT NULL,
    aktualni_misto_pobytu VARCHAR(100) NOT NULL,
    pohlavi VARCHAR(100) NOT NULL,
    oblibeny_druh_pripravy_kavy VARCHAR(100) NOT NULL,
    pocet_vypitych_kav NUMBER(2) DEFAULT 0,
    id_kavy NUMBER REFERENCES druh_kavy(id_kavy)
);

CREATE TABLE kavarna(
    ico number(8,0) NOT NULL PRIMARY KEY
    CHECK(mod(11 - mod(8 * trunc(ico/10000000) + 7 * mod(trunc(ico/1000000), 10) + 6 * mod(trunc(ico/100000), 10) + 5 * mod(trunc(ico/10000), 10) + 4 * mod(trunc(ico/1000), 10) + 3 * mod(trunc(ico/100), 10) + 2 * mod(trunc(ico/10), 10), 11), 10) = mod(ico, 10)),
    adresa VARCHAR(100) NOT NULL,
    nazev VARCHAR(100) NOT NULL,
    kapacita NUMBER,
    popis VARCHAR(100) NOT NULL
);

--pro umozneni zadavani ruznych oteviracich dob kavarny v ruznych  dnech, pridaly jsme entitu provozni doba
CREATE TABLE provozni_doba(
    ico NUMBER(8,0) NOT NULL,
    den_v_tydnu VARCHAR(50) NOT NULL,
    otevreno_od VARCHAR(10) NOT NULL,
    otevreno_do VARCHAR(10) NOT NULL,
    FOREIGN KEY(ico) REFERENCES kavarna(ico)
);

CREATE TABLE cupping_akce(
    id_akce NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    datum_konani VARCHAR(100) NOT NULL,
    cas_konani_od VARCHAR(5) NOT NULL,
    cas_konani_do VARCHAR(5) NOT NULL,
    cena NUMBER(4) DEFAULT 0,
    pocet_volnych_mist NUMBER,
    id_zamestnance NUMBER REFERENCES majitel(id_zamestnance),
    ico REFERENCES kavarna(ico)
);

CREATE TABLE recenze(
    id_uzivatele NUMBER,
    id_recenzi NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1 UNIQUE NOT NULL,
    text_recenzi VARCHAR(100) NOT NULL,
    pocet_hvezdicek INT NOT NULL,
    CHECK(pocet_hvezdicek >= 0 AND pocet_hvezdicek <= 5),
    datum_navstevy DATE,
    datum_publikovani_recenze TIMESTAMP default CURRENT_TIMESTAMP,
    FOREIGN KEY(id_uzivatele) REFERENCES uzivatel(id_uzivatele),
    id_akce REFERENCES cupping_akce(id_akce),
    ico REFERENCES kavarna(ico)
);

CREATE TABLE reakce(
    id_recenzi NUMBER,
    id_reakce NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1,
    text_reakci VARCHAR(100) NOT NULL,
    datum_publikovani_reakce DATE NOT NULL,
    pocet_palcu_nahoru number not null,
    pocet_palcu_dolu number not null,
    FOREIGN KEY(id_recenzi) REFERENCES recenze(id_recenzi),
    id_zamestnance REFERENCES zamestnanec(id_zamestnance),
    id_uzivatele REFERENCES uzivatel(id_uzivatele),
    CHECK(id_uzivatele is NULL or id_zamestnance is NULL)
);



CREATE TABLE druh_kavoveho_zrna(
    id_druhu_zrna NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    odruda VARCHAR(50) NOT NULL,
    stupen_kyselosti INT NOT NULL
    CHECK(stupen_kyselosti >= 0 AND stupen_kyselosti <= 5),
    aromat VARCHAR(50) NOT NULL,
    chut VARCHAR(50) NOT NULL
);

 CREATE TABLE druh_kavy_druh_kavoveho_zrna(
    id_kavy NUMBER UNIQUE NOT NULL,
    id_druhu_zrna NUMBER UNIQUE NOT NULL,
    FOREIGN KEY (id_kavy) REFERENCES druh_kavy(id_kavy), 
    FOREIGN KEY (id_druhu_zrna) REFERENCES druh_kavoveho_zrna(id_druhu_zrna)
);

 CREATE TABLE druh_kavy_cupping_akce(
     id_kavy NUMBER UNIQUE NOT NULL,
     id_akce NUMBER UNIQUE NOT NULL,
     FOREIGN KEY (id_kavy) REFERENCES druh_kavy(id_kavy), 
     FOREIGN KEY (id_akce) REFERENCES cupping_akce(id_akce)
);
 CREATE TABLE majitel_kavarna(
     id_zamestnance NUMBER UNIQUE NOT NULL,
     ico NUMBER UNIQUE NOT NULL,
     FOREIGN KEY (id_zamestnance) REFERENCES majitel(id_zamestnance), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);

 CREATE TABLE uzivatel_kavarna(
     id_uzivatele NUMBER UNIQUE NOT NULL,
     ico NUMBER UNIQUE NOT NULL,
     FOREIGN KEY (id_uzivatele) REFERENCES uzivatel(id_uzivatele), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);

 CREATE TABLE zamestnanec_kavarna(
     id_zamestnance NUMBER UNIQUE NOT NULL,
     ico NUMBER UNIQUE NOT NULL,
     FOREIGN KEY (id_zamestnance) REFERENCES zamestnanec(id_zamestnance), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);
alter session set NLS_TIMESTAMP_FORMAT = 'dd.mm.yyyyhh24:mi:ss';
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Karel', 'Orsag', 'cisnik');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Irena', 'Sladka', 'servirka');
insert into majitel values (2);
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Russia','vysoka','cokolada');
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Cina','vysoka','slana karamel');
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Spanelsko','vysoka','bila cokolada');
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi, oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Pavel', 'Klasek', '14.09.1978','Praha','muz','videnska',6,1);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi, oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Klara', 'Pronina', '01.07.1999','Olomouc','zena','latte',4,1);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi, oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Jaroslav', 'Divny', '12.10.2000','Brno','muz','cappucino',1,2);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi, oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Alena', 'Klusackova', '04.02.1963','Praha','zena','flat white',3,3);
insert into kavarna values(26168685, 'ceska', 'SKOG',100,'oblibena kavarna s ruznymi druhy kavy');
insert into kavarna values(45308314, 'veveri', 'Silver',58,'kocici kavarna');
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values( 26168685, 'streda a patek', '08:00', '22:00');
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values( 45308314, 'kazdy den', '10:00', '20:00');
insert into cupping_akce(datum_konani,cas_konani_od, cas_konani_do,cena, pocet_volnych_mist,ico)values ('2021:04:14', '10:00', '17:00', 350, 159,26168685);
insert into cupping_akce(datum_konani,cas_konani_od, cas_konani_do,cena, pocet_volnych_mist,ico)values ('2021:02:27', '09:00', '15:00', 430, 200,45308314);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (1,'meli jsme tady snidane,to bylo nejlepsi rano, velmi chutna kava a croissant',4,'15.03.2021',1,26168685);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (2,'nejlepsi kavarna v Cesku',5,'19.04.2015',2,45308314);
insert into reakce(text_reakci,datum_publikovani_reakce, pocet_palcu_nahoru,pocet_palcu_dolu, id_uzivatele,id_recenzi) values ('super hezka kavarna','15.03.2021', 73, 6, 1,1);
insert into reakce(text_reakci,datum_publikovani_reakce, pocet_palcu_nahoru,pocet_palcu_dolu, id_uzivatele,id_recenzi) values ('chodim tam kazdy den celou rodinou, nejlepsi vyber ve meste','10.01.2021', 58, 4, 3,2);
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('arabica',3,'horky','karamel');
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('robusta',4,'horky','vanilka');

--select * from zamestnanec;
--select * from zamestnanec
--inner join majitel
--on zamestnanec.id_zamestnance = majitel.id_zamestnance;
--select * from druh_kavy; 
--select * from uzivatel;
--select * from kavarna;
--select * from provozni_doba;
--select * from cupping_akce;
--select * from recenze;
--select * from reakce;
--select * from druh_kavoveho_zrna;