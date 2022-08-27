set serveroutput on;
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

--DROP INDEX index_kavarna;
DROP MATERIALIZED VIEW Kava;

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
    ico number(8,0) NOT NULL PRIMARY KEY,
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
    id_akce NUMBER NOT NULL
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
    datum_navstevy VARCHAR(100),
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
    id_druh_kavy_druh_kavoveho_zrna NUMBER GENERATED ALWAYS AS
    IDENTITY START with 1 INCREMENT by 1
    PRIMARY KEY,
    id_kavy NUMBER NOT NULL,
    id_druhu_zrna NUMBER NOT NULL,
    FOREIGN KEY (id_kavy) REFERENCES druh_kavy(id_kavy), 
    FOREIGN KEY (id_druhu_zrna) REFERENCES druh_kavoveho_zrna(id_druhu_zrna)
);

 CREATE TABLE druh_kavy_cupping_akce(
     id_druh_kavy_cupping_akce NUMBER GENERATED ALWAYS AS
     IDENTITY START with 1 INCREMENT by 1
     PRIMARY KEY,
     id_kavy NUMBER NOT NULL,
     id_akce NUMBER NOT NULL,
     FOREIGN KEY (id_kavy) REFERENCES druh_kavy(id_kavy), 
     FOREIGN KEY (id_akce) REFERENCES cupping_akce(id_akce)
);
 CREATE TABLE majitel_kavarna(
     id_majitel_kavarna NUMBER GENERATED ALWAYS AS
     IDENTITY START with 1 INCREMENT by 1
     PRIMARY KEY,
     id_zamestnance NUMBER NOT NULL,
     ico NUMBER NOT NULL,
     FOREIGN KEY (id_zamestnance) REFERENCES majitel(id_zamestnance), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);

 CREATE TABLE uzivatel_kavarna(
     id_uzivatel_kavarna NUMBER GENERATED ALWAYS AS
     IDENTITY START with 1 INCREMENT by 1
     PRIMARY KEY,
     id_uzivatele NUMBER NOT NULL,
     ico NUMBER NOT NULL,
     FOREIGN KEY (id_uzivatele) REFERENCES uzivatel(id_uzivatele), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);

 CREATE TABLE zamestnanec_kavarna(
     id_zamestnanec_kavarna NUMBER GENERATED ALWAYS AS
     IDENTITY START with 1 INCREMENT by 1
     PRIMARY KEY,
     id_zamestnance NUMBER NOT NULL,
     ico NUMBER NOT NULL,
     FOREIGN KEY (id_zamestnance) REFERENCES zamestnanec(id_zamestnance), 
     FOREIGN KEY (ico) REFERENCES kavarna(ico)
);

--trigger pro automaticke generovani hodnot primarniho klice cupping akce
SET TIMING ON;
CREATE OR REPLACE TRIGGER trigger_cupping_akce
	BEFORE INSERT OR UPDATE ON cupping_akce
	FOR EACH ROW
BEGIN
	IF :new.id_akce is null THEN
	   :new.id_akce := TO_NUMBER(sys_guid(), 'XXXXXXXXXXXXX');
	END IF;
END;
/
show errors
SET TIMING OFF;

-- validace ico kavarny
CREATE OR REPLACE TRIGGER trigger_ico
	BEFORE INSERT OR UPDATE ON kavarna
	FOR EACH ROW
    DECLARE
    INVALID_ICO EXCEPTION;
BEGIN
	IF (mod(11 - mod(8 * trunc(:new.ico/10000000) + 7 * mod(trunc(:new.ico/1000000), 10) + 6 * mod(trunc(:new.ico/100000), 10) + 5 * mod(trunc(:new.ico/10000), 10) + 4 * mod(trunc(:new.ico/1000), 10) + 3 * mod(trunc(:new.ico/100), 10) + 2 * mod(trunc(:new.ico/10), 10), 11), 10) <> mod(:new.ico, 10))
    THEN
        Raise INVALID_ICO;
	END IF;
    exception
    when INVALID_ICO THEN
        DBMS_OUTPUT.PUT_LINE('Nevalidne ico: '||:new.ico||'');
    
END;
/
show errors

insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Karel', 'Orsag', 'cisnik');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Irena', 'Sladka', 'servirka');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Dana', 'Novotna', 'servirka');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Jaroslav', 'Millet', 'cisnik');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Ivan', 'Bobrov', 'admin');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Dima', 'Kozhevnikov', 'stavitel');
insert into zamestnanec (jmeno,prijmeni,pracovni_pozice) values ('Yahor', 'Senichak', 'barman');
insert into majitel values (2);
insert into majitel values (3);
insert into majitel values (1);
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Russia','vysoka','cokolada');
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Cina','vysoka','slana karamel');
insert into druh_kavy (oblast_puvodu,kvalita,chut)values('Spanelsko','vysoka','bila cokolada');
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi,oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Pavel', 'Klasek', '14.09.1978','Praha','muz','videnska',6,1);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi,oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Klara', 'Pronina', '01.07.1999','Olomouc','zena','latte',4,1);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi,oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Jaroslav', 'Divny', '12.10.2000','Brno','muz','cappucino',1,2);
insert into uzivatel (jmeno,prijmeni,datum_narozeni,aktualni_misto_pobytu,pohlavi,oblibeny_druh_pripravy_kavy,pocet_vypitych_kav,id_kavy)values('Alena', 'Klusackova', '04.02.1963','Praha','zena','flat white',3,3);
insert into kavarna values(26168685, 'ceska', 'SKOG',400,'oblibena kavarna s ruznymi druhy kavy');
insert into kavarna values(45308314, 'veveri', 'Silver',508,'kocici kavarna');
insert into kavarna values(47114983, 'tererova', 'Shrek',750,'kafe');
insert into kavarna values(50626396, 'mira', 'Sarlota',650,'restaurace');
insert into kavarna values(50626391, 'bbbbbbbb', 'Sarlota',22,'restaurace');
insert into majitel_kavarna (id_zamestnance, ico) values(2,26168685);
insert into majitel_kavarna (id_zamestnance, ico) values(3,47114983);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(1,26168685);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(2,45308314);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(3,45308314);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(4,26168685);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(5,45308314);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(6,45308314);
insert into zamestnanec_kavarna (id_zamestnance, ico) values(7,45308314);
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values(26168685, 'streda', '08:00', '22:00');
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values(45308314 , 'streda', '10:00', '20:00');
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values(26168685, 'patek', '08:00', '22:00');
insert into provozni_doba (ico, den_v_tydnu, otevreno_od, otevreno_do) values(45308314, 'kazdy den', '10:00', '20:00');
insert into cupping_akce(id_akce,datum_konani,cas_konani_od, cas_konani_do,cena, pocet_volnych_mist,ico)values (1,'2021.04.14', '10:00', '17:00', 23, 159,26168685);
insert into cupping_akce(id_akce,datum_konani,cas_konani_od, cas_konani_do,cena, pocet_volnych_mist,ico)values (2,'2021.02.27', '09:00', '15:00', 56, 200,45308314);
insert into cupping_akce(id_akce,datum_konani,cas_konani_od, cas_konani_do,cena, pocet_volnych_mist,ico)values (3,'2021.04.16', '10:00', '17:00', 100, 0,47114983);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (1,'meli jsme tady snidane,to bylo nejlepsi rano, velmi chutna kava a croissant',3,'15.03.2021',1,26168685);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (2,'velmi rychle se pripravuji a chutna',5,'19.04.2015',2,45308314);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (2,'nejlepsi kavarna ve svete',5,'2021.02.27',3,45308314);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,id_akce,ico) values (1,'velky vyber kavy a dezertu',4,'2021.04.14',2,45308314);
insert into recenze(id_uzivatele,text_recenzi, pocet_hvezdicek,datum_navstevy,ico) values (2,'nejlepsi kavarna',4,'19.04.2015',47114983);
insert into reakce(text_reakci,datum_publikovani_reakce, pocet_palcu_nahoru,pocet_palcu_dolu, id_zamestnance,id_recenzi) values ('super hezka kavarna','15.03.2021', 73, 6, 1,1);
insert into reakce(text_reakci,datum_publikovani_reakce, pocet_palcu_nahoru,pocet_palcu_dolu, id_zamestnance,id_recenzi) values ('super kavarna','25.11.2020', 43, 16, 2,2);
insert into reakce(text_reakci,datum_publikovani_reakce, pocet_palcu_nahoru,pocet_palcu_dolu, id_uzivatele,id_recenzi) values ('chodim tam kazdy den celou rodinou, nejlepsi vyber ve meste','10.01.2021', 58, 4, 3,2);
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('arabica',3,'oriskovy','karamel');
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('robusta',4,'kvetny','vanilka');
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('arabica',5,'bylinny','candy');
insert into druh_kavoveho_zrna (odruda,stupen_kyselosti,aromat,chut) values('robusta',3,'matovy','citrus');
insert into druh_kavy_druh_kavoveho_zrna (id_kavy,id_druhu_zrna) values (1,2);
insert into druh_kavy_druh_kavoveho_zrna (id_kavy,id_druhu_zrna) values (2,1);
insert into druh_kavy_druh_kavoveho_zrna (id_kavy,id_druhu_zrna) values (1,3);
insert into druh_kavy_druh_kavoveho_zrna (id_kavy,id_druhu_zrna) values (2,4);

--hledani kavaren ktere jsou otevrene ve stredu
select kavarna.nazev,provozni_doba.den_v_tydnu, provozni_doba.otevreno_od, provozni_doba.otevreno_do
from kavarna
inner join provozni_doba
on kavarna.ico = provozni_doba.ico
WHERE provozni_doba.den_v_tydnu = 'streda';

--vypis textu reakci zamestnance
select zamestnanec.jmeno,zamestnanec.prijmeni, zamestnanec.pracovni_pozice, reakce.text_reakci
from zamestnanec join reakce
on zamestnanec.id_zamestnance = reakce.id_zamestnance;

--vypis oblasti puvodu druhu kavy a aromatu kavoveho zrna za podminky ze chut je vanilka nebo karamel
select druh_kavy.oblast_puvodu, druh_kavoveho_zrna.aromat
from druh_kavy join druh_kavy_druh_kavoveho_zrna
on druh_kavy.id_kavy = druh_kavy_druh_kavoveho_zrna.id_kavy JOIN
druh_kavoveho_zrna
on druh_kavoveho_zrna.id_druhu_zrna = druh_kavy_druh_kavoveho_zrna.id_druhu_zrna
WHERE druh_kavoveho_zrna.chut = 'vanilka' or druh_kavoveho_zrna.chut = 'karamel';

--vypis jmen majitelu a nazvu kavaren ktere vlastni 
select zamestnanec.jmeno,zamestnanec.prijmeni, kavarna.nazev
from zamestnanec join majitel
on majitel.id_zamestnance = zamestnanec.id_zamestnance join
majitel_kavarna
on majitel_kavarna.id_zamestnance = majitel.id_zamestnance join
kavarna
on kavarna.ico = majitel_kavarna.ico;

--vypis prumerneho poctu hvezdicek pro kazdou kavarnu
SELECT kavarna.nazev, AVG(recenze.pocet_hvezdicek)FROM kavarna
LEFT JOIN recenze ON recenze.ico = kavarna.ico
GROUP BY kavarna.nazev
ORDER BY AVG(recenze.pocet_hvezdicek) DESC;

--vypis poctu zamestnancu v kazde kavarne
SELECT kavarna.nazev, COUNT(zamestnanec.id_zamestnance)FROM kavarna
JOIN zamestnanec_kavarna ON zamestnanec_kavarna.ico = kavarna.ico 
JOIN zamestnanec ON zamestnanec.id_zamestnance = zamestnanec_kavarna.id_zamestnance
GROUP BY kavarna.nazev;

--vypis kavaren s poctem volnych mist na akci, pokud jsou volna mista aspon na jedne akci
SELECT kavarna.nazev,kavarna.adresa, cupping_akce.pocet_volnych_mist
  FROM kavarna JOIN cupping_akce on kavarna.ico = cupping_akce.ico
  WHERE EXISTS
  (SELECT * FROM cupping_akce 
    WHERE cupping_akce.pocet_volnych_mist > 0)
   ORDER BY cupping_akce.pocet_volnych_mist DESC;
   
--vypis textu recenze o kavarnach ktere uzivatele napsali po navsteve cupping akce
SELECT recenze.text_recenzi, recenze.pocet_hvezdicek, cupping_akce.datum_konani
FROM recenze JOIN cupping_akce on recenze.id_akce = cupping_akce.id_akce 
WHERE recenze.datum_navstevy IN (SELECT cupping_akce.datum_konani FROM cupping_akce);

--procedura pro vypocet daně kavaren z akce v Cesku
CREATE OR REPLACE PROCEDURE average_cupping_akce IS
  CURSOR akce IS SELECT kavarna.kapacita,cupping_akce.cena,cupping_akce.pocet_volnych_mist
  FROM kavarna JOIN cupping_akce on kavarna.ico = cupping_akce.ico;
  tmp akce%ROWTYPE;
  pocet_obsaz NUMBER;
  zisk NUMBER;
  dan NUMBER;

  BEGIN
    zisk:= 0;
    pocet_obsaz:= 0;
    OPEN akce;
    LOOP
      FETCH akce INTO tmp;
      EXIT WHEN akce%NOTFOUND;
        pocet_obsaz := tmp.kapacita - tmp.pocet_volnych_mist;
        zisk := zisk + pocet_obsaz*tmp.cena;
    END LOOP;
    dan := ROUND(zisk* 0.15);
    dbms_output.put_line('Zisk statu z cupping akce se rovna : ' || dan );
    CLOSE akce;
  END;
/
EXECUTE average_cupping_akce();

--procedura2 pro vypocet vypitych kav ve meste
CREATE OR REPLACE PROCEDURE average_pocet_kav_ve_meste(mesto IN VARCHAR) IS
  CURSOR kava IS SELECT uzivatel.aktualni_misto_pobytu,uzivatel.pocet_vypitych_kav FROM uzivatel;
  tmp kava%ROWTYPE;
  pocet_kav NUMBER;
  counter NUMBER;

  BEGIN
    pocet_kav:= 0;
    OPEN kava;
    LOOP
      FETCH kava INTO tmp;
      EXIT WHEN kava%NOTFOUND;
          IF (tmp.aktualni_misto_pobytu = mesto) THEN
                pocet_kav := pocet_kav + tmp.pocet_vypitych_kav;
            END IF;
    END LOOP;
     counter:= pocet_kav/kava%ROWCOUNT;
     dbms_output.put_line('Pocet vypitych kav ve meste ' || mesto ||' je: ' || counter );
     CLOSE kava;
    EXCEPTION
	WHEN ZERO_DIVIDE THEN
	dbms_output.put_line('Neni zadny uzivatel v meste : ' || mesto );
    
  END;
/
EXECUTE average_pocet_kav_ve_meste('Praha');

--pristupova prava-- 

GRANT ALL ON zamestnanec TO xcaras00;
GRANT ALL ON majitel TO xcaras00;
GRANT ALL ON druh_kavy TO xcaras00;
GRANT ALL ON uzivatel TO xcaras00;
GRANT ALL ON kavarna TO xcaras00;
GRANT ALL ON provozni_doba TO xcaras00;
GRANT ALL ON cupping_akce TO xcaras00;
GRANT ALL ON recenze TO xcaras00;
GRANT ALL ON reakce TO xcaras00;
GRANT ALL ON druh_kavoveho_zrna TO xcaras00;
GRANT ALL ON provozni_doba TO xcaras00;
GRANT ALL ON cupping_akce TO xcaras00;
GRANT ALL ON recenze TO xcaras00;
GRANT ALL ON reakce TO xcaras00;
GRANT ALL ON druh_kavoveho_zrna TO xcaras00;
GRANT ALL ON druh_kavy_druh_kavoveho_zrna TO xcaras00;
GRANT ALL ON druh_kavy_cupping_akce TO xcaras00;
GRANT ALL ON majitel_kavarna TO xcaras00;
GRANT ALL ON uzivatel_kavarna TO xcaras00;
GRANT ALL ON zamestnanec_kavarna TO xcaras00;

GRANT EXECUTE ON average_cupping_akce TO xcaras00;
GRANT EXECUTE ON average_pocet_kav_ve_meste TO xcaras00;

-----------EXPLAIN PLAN---------
EXPLAIN PLAN FOR
SELECT count(id_zamestnance),nazev FROM zamestnanec NATURAL JOIN kavarna GROUP BY nazev,id_zamestnance;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.display);

CREATE INDEX index_kavarna ON kavarna (nazev);

EXPLAIN PLAN FOR
SELECT count(id_zamestnance),nazev FROM zamestnanec NATURAL JOIN kavarna GROUP BY nazev,id_zamestnance;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.display);

--------  MATERIALIZED VIEW ----------

CREATE MATERIALIZED VIEW LOG ON druh_kavy WITH PRIMARY KEY, ROWID(chut) INCLUDING NEW VALUES;
CREATE MATERIALIZED VIEW Kava
CACHE                       
BUILD IMMEDIATE             
REFRESH FAST ON COMMIT      
ENABLE QUERY REWRITE        
AS SELECT tmp.chut, count(tmp.chut) as pocet
FROM druh_kavy tmp
GROUP BY tmp.chut;

SELECT * FROM Kava;

INSERT INTO druh_kavy(oblast_puvodu, kvalita, chut) values ('Belorusko','vysoka','vanilka');

COMMIT;

SELECT * FROM Kava;

GRANT SELECT, UPDATE 
   ON Kava TO xcaras00;
