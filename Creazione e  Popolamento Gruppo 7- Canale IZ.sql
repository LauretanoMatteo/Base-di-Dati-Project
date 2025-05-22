/*CREAZIONE*/
DROP SEQUENCE IF EXISTS my_sequence_frasi CASCADE;
CREATE SEQUENCE my_sequence_frasi START 1;

DROP SEQUENCE IF EXISTS my_sequence_proposizioni CASCADE;
CREATE SEQUENCE my_sequence_proposizioni START 1;

DROP SEQUENCE IF EXISTS my_sequence_indirizzi CASCADE;
CREATE SEQUENCE my_sequence_indirizzi START 1000000000;

DROP DOMAIN IF EXISTS range_punteggio;
CREATE DOMAIN range_punteggio AS numeric CHECK(VALUE >=0 AND VALUE <= 1);

DROP DOMAIN IF EXISTS formatPartitaIva CASCADE;
CREATE DOMAIN formatPartitaIva AS char(11) CHECK(VALUE >='0' AND VALUE <= '9');

DROP DOMAIN IF EXISTS formatRecensione CASCADE;
CREATE DOMAIN formatRecensione AS char(10) CHECK(VALUE >= '0' AND VALUE <= '9');

DROP TABLE IF EXISTS Proprietario CASCADE;
CREATE TABLE IF NOT EXISTS public.Proprietario
(
    Username varchar(30) NOT NULL,
    Nome varchar(30) NOT NULL,
    Cognome varchar NOT NULL,
	Genere varchar(20) NOT NULL,
    Codice_Fiscale varchar(20) NOT NULL,
    ID_Indirizzo_di_residenza integer,
    ID_Indirizzo_legale integer,
    Codice_Postale_Città_di_Nascita varchar(20),
    Data_di_Nascita date NOT NULL,
    Indirizzo_E_mail varchar(30) NOT NULL,
    Telefono varchar(15) NOT NULL,
    Valuta varchar(20) NOT NULL,
    Partita_IVA formatPartitaIva NOT NULL,
    Posta_Elettronica_Certificata varchar(20) NOT NULL,
    Breve_descrizione text,
    PRIMARY KEY (Username),
	UNIQUE(Partita_IVA),
    UNIQUE (Codice_Fiscale),
	UNIQUE (Indirizzo_E_mail),
	UNIQUE (Posta_Elettronica_Certificata),
	
	CONSTRAINT check_sesso CHECK (Genere IN ('Uomo','Donna','Non binario','Preferisco non dirlo')),
	CONSTRAINT check_e_mail CHECK (Indirizzo_E_mail LIKE '%@%.%'),
	CONSTRAINT check_lunghezza_descrizione CHECK(LENGTH(Breve_descrizione) BETWEEN 15 AND 500)
);

DROP TABLE IF EXISTS Cliente CASCADE;
CREATE TABLE IF NOT EXISTS public.Cliente
(
    Username varchar(30) NOT NULL,
    Nome varchar(30) NOT NULL,
    Cognome varchar(30) NOT NULL,
    Genere varchar(20) NOT NULL,
    Codice_Fiscale varchar(20) NOT NULL,
    ID_Indirizzo_di_residenza integer,
    Codice_Postale_Città_di_Nascita varchar(20),
    Data_di_Nascita date NOT NULL,
    Indirizzo_E_mail varchar(30) NOT NULL,
    Telefono varchar(15) NOT NULL,
    Valuta varchar(20) NOT NULL,
    Contatto_di_emergenza varchar(15) NOT NULL,
    PRIMARY KEY (Username),
    UNIQUE (Codice_Fiscale),
	UNIQUE (Indirizzo_E_mail),
	CONSTRAINT check_sesso CHECK(Genere IN ('Uomo','Donna','Non binario','Preferisco non dirlo')),
	CONSTRAINT check_e_mail CHECK (Indirizzo_E_mail LIKE '%@%.%')

);

DROP TABLE IF EXISTS BnB CASCADE;
CREATE TABLE IF NOT EXISTS public.BnB
(
    CIR varchar(30) NOT NULL,
    Nome varchar(30) NOT NULL,
    ID_Indirizzo integer,
    Telefono varchar(15) NOT NULL,
    Numero_di_stanze integer NOT NULL,
    Numero_di_recensioni integer NOT NULL DEFAULT 0,
    Anno_di_iscrizione date,
    Orario_Check_in time without time zone NOT NULL,
    Orario_Check_out time without time zone NOT NULL,
    Breve_descrizione text NOT NULL,
    PRIMARY KEY (CIR),
	
	CONSTRAINT check_lunghezza_descrizione CHECK(LENGTH(Breve_descrizione)BETWEEN 50 AND 1000 ),
	CONSTRAINT check_numero_stanze CHECK(Numero_di_stanze > 0)	
	
);

DROP TABLE IF EXISTS Recensione CASCADE;
CREATE TABLE IF NOT EXISTS public.Recensione
(
    ID_Recensione formatRecensione NOT NULL,
    Autore_recensione varchar(20) NOT NULL,
    CIR_BnB varchar(20) NOT NULL,
    Data_pubblicazione date NOT NULL,
    Data_inizio_pernottamento date NOT NULL,
    Data_fine_pernottamento date NOT NULL,
    Testo_della_recensione text NOT NULL,
    Visibilità boolean NOT NULL,
    PRIMARY KEY (ID_Recensione),
	CONSTRAINT check_data_pubblicazione CHECK(Data_pubblicazione >= Data_fine_pernottamento),
	CONSTRAINT check_lunghezza_testo_recensione CHECK(LENGTH(Testo_della_recensione) BETWEEN 50 AND 1000 )
);

DROP TABLE IF EXISTS Fine_Validità CASCADE;
CREATE TABLE IF NOT EXISTS public.Fine_Validità
(
    Data_pubblicazione date NOT NULL,
    Data_fine_validità date NOT NULL,
    PRIMARY KEY (Data_pubblicazione)
);

DROP TABLE IF EXISTS Città CASCADE;
CREATE TABLE IF NOT EXISTS public.Città
(
    Codice_Postale varchar(10) NOT NULL,
    Nome varchar(30) NOT NULL,
    Paese varchar(20) NOT NULL,
    PRIMARY KEY (Codice_Postale)
);

DROP TABLE IF EXISTS Indirizzo CASCADE;
CREATE TABLE IF NOT EXISTS public.Indirizzo
(
    ID_Indirizzo integer NOT NULL DEFAULT nextval('my_sequence_indirizzi'),
    Codice_Postale_Città varchar(20) NOT NULL,
    Tipo_infrastruttura varchar(20) NOT NULL,
    Intestazione_infrastruttura varchar(30) NOT NULL,
    Numero_civico integer NOT NULL,
    PRIMARY KEY (ID_Indirizzo)
);

DROP TABLE IF EXISTS Proposizione CASCADE;
CREATE TABLE IF NOT EXISTS public.Proposizione
(
    ID_Recensione formatRecensione NOT NULL,
    ID_Frase varchar NOT NULL,
    ID_Proposizione varchar NOT NULL,
    PRIMARY KEY (ID_Recensione, ID_Frase, ID_Proposizione)
);

DROP TABLE IF EXISTS Proposizione_ID CASCADE;
CREATE TABLE IF NOT EXISTS public.Proposizione_ID
(
    ID_Proposizione varchar(15) DEFAULT CONCAT('P',nextval('my_sequence_proposizioni')::varchar),
    Testo_della_proposizione text NOT NULL,
    PRIMARY KEY (ID_Proposizione)
);

DROP TABLE IF EXISTS Valutazione CASCADE;
CREATE TABLE IF NOT EXISTS public.Valutazione
(
    Testo_della_proposizione text NOT NULL,
    Punteggio_Sentiment numeric NOT NULL,
    Tipo_aspect varchar(20) NOT NULL,
    PRIMARY KEY (Testo_della_proposizione)
);

DROP TABLE IF EXISTS Adiacenza CASCADE;
CREATE TABLE IF NOT EXISTS public.Adiacenza
(
    CIR_BnB varchar(20) NOT NULL,
    ID_Indirizzo_Punto_di_interesse integer NOT NULL,
    Distanza numeric NOT NULL,
    PRIMARY KEY (CIR_BnB, ID_Indirizzo_Punto_di_interesse),
	
	CONSTRAINT check_distanza CHECK(Distanza < 5) /*si intente di 5Km*/
);

DROP TABLE IF EXISTS Lingue_parlate CASCADE;
CREATE TABLE IF NOT EXISTS public.Lingue_parlate
(
    Lingua varchar(20) NOT NULL,
    PRIMARY KEY (Lingua)
);

DROP TABLE IF EXISTS Lingua_Proprietario CASCADE;
CREATE TABLE IF NOT EXISTS public.Lingua_Proprietario
(
    Lingua varchar(20) NOT NULL,
    Proprietario varchar(20) NOT NULL,
    PRIMARY KEY (Lingua, Proprietario)
);

DROP TABLE IF EXISTS Allergia_o_Intolleranza CASCADE;
CREATE TABLE IF NOT EXISTS public.Allergia_o_Intolleranza
(
    Nome varchar(20) NOT NULL,
    PRIMARY KEY (Nome)
);

DROP TABLE IF EXISTS Allergia_o_intolleranza_Cliente CASCADE;
CREATE TABLE IF NOT EXISTS public.Allergia_o_Intolleranza_Cliente
(
    Allergia_o_Intolleranza varchar(20) NOT NULL DEFAULT 'Nessuno',
    Cliente varchar(20) NOT NULL,
    PRIMARY KEY (Allergia_o_Intolleranza, Cliente)
);

DROP TABLE IF EXISTS Frase_Complessa CASCADE;
CREATE TABLE IF NOT EXISTS public.Frase_Complessa
(
    ID_Recensione formatRecensione NOT NULL,
    ID_Frase varchar(11) NOT NULL,
    PRIMARY KEY (ID_Recensione, ID_Frase)
);

DROP TABLE IF EXISTS Frase_Complessa_ID CASCADE;
CREATE TABLE IF NOT EXISTS public.Frase_Complessa_ID
(
    ID_Frase varchar(11) DEFAULT CONCAT('F',nextval('my_sequence_frasi')::varchar),
    Testo_della_frase text NOT NULL,
    PRIMARY KEY (ID_Frase)
);

DROP TABLE IF EXISTS Immagine_BnB CASCADE;
CREATE TABLE IF NOT EXISTS public.Immagine_BnB
(
    Immagine bytea NOT NULL,
    CIR_BnB varchar(20) NOT NULL,
    PRIMARY KEY (Immagine)
);

DROP TABLE IF EXISTS Punto_di_interesse CASCADE;
CREATE TABLE IF NOT EXISTS public.Punto_di_Interesse
(
    ID_Indirizzo integer NOT NULL,
    Nome varchar(50) NOT NULL,
    Descrizione varchar(100),
    Categoria varchar(50) NOT NULL,
    PRIMARY KEY (ID_Indirizzo)
);

DROP TABLE IF EXISTS Proprietà CASCADE;
CREATE TABLE IF NOT EXISTS public.Proprietà
(
    Proprietario varchar(20) NOT NULL,
    CIR_BnB varchar(20) NOT NULL,
    PRIMARY KEY (Proprietario, CIR_BnB)
);

ALTER TABLE IF EXISTS public.Proprietario
    ADD FOREIGN KEY (ID_Indirizzo_di_residenza)
    REFERENCES public.Indirizzo (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Proprietario
    ADD FOREIGN KEY (ID_Indirizzo_legale)
    REFERENCES public.Indirizzo (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Proprietario
    ADD FOREIGN KEY (Codice_Postale_Città_di_Nascita)
    REFERENCES public.Città (Codice_Postale) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Cliente
    ADD FOREIGN KEY (ID_Indirizzo_di_residenza)
    REFERENCES public.Indirizzo (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Cliente
    ADD FOREIGN KEY (Codice_Postale_Città_di_Nascita)
    REFERENCES public.Città (Codice_Postale) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.BnB
    ADD FOREIGN KEY (ID_Indirizzo)
    REFERENCES public.Indirizzo (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Recensione
    ADD FOREIGN KEY (Data_pubblicazione)
    REFERENCES public.Fine_Validità (Data_pubblicazione) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
    NOT VALID;


ALTER TABLE IF EXISTS public.Recensione
    ADD FOREIGN KEY (Autore_recensione)
    REFERENCES public.Cliente (Username) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    NOT VALID;


ALTER TABLE IF EXISTS public.Recensione
    ADD FOREIGN KEY (CIR_BnB)
    REFERENCES public.BnB (CIR) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Indirizzo
    ADD FOREIGN KEY (Codice_Postale_Città)
    REFERENCES public.Città (Codice_Postale) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Proposizione
    ADD FOREIGN KEY (ID_Proposizione)
    REFERENCES public.Proposizione_ID (ID_Proposizione) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    NOT VALID;


ALTER TABLE IF EXISTS public.Proposizione
    ADD FOREIGN KEY (ID_Recensione, ID_Frase)
    REFERENCES public.Frase_Complessa (ID_Recensione, ID_Frase) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Proposizione_ID
    ADD FOREIGN KEY (Testo_della_proposizione)
    REFERENCES public.Valutazione (Testo_della_proposizione) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    NOT VALID;


ALTER TABLE IF EXISTS public.Adiacenza
    ADD FOREIGN KEY (CIR_BnB)
    REFERENCES public.BnB (CIR) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Adiacenza
    ADD FOREIGN KEY (ID_Indirizzo_Punto_di_interesse)
    REFERENCES public.Punto_di_Interesse (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Lingua_Proprietario
    ADD FOREIGN KEY (Lingua)
    REFERENCES public.Lingue_parlate (Lingua) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Lingua_Proprietario
    ADD FOREIGN KEY (Proprietario)
    REFERENCES public.Proprietario (Username) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Allergia_o_Intolleranza_Cliente
    ADD FOREIGN KEY (Cliente)
    REFERENCES public.Cliente (Username) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    DEFERRABLE INITIALLY DEFERRED
    NOT VALID;


ALTER TABLE IF EXISTS public.Allergia_o_Intolleranza_Cliente
    ADD FOREIGN KEY (Allergia_o_Intolleranza)
    REFERENCES public.Allergia_o_Intolleranza (Nome) MATCH SIMPLE
    ON UPDATE RESTRICT
    ON DELETE SET DEFAULT
    DEFERRABLE INITIALLY DEFERRED
    NOT VALID;


ALTER TABLE IF EXISTS public.Frase_Complessa
    ADD FOREIGN KEY (ID_Recensione)
    REFERENCES public.Recensione (ID_Recensione) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Frase_Complessa
    ADD FOREIGN KEY (ID_Frase)
    REFERENCES public.Frase_Complessa_ID (ID_Frase) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    NOT VALID;


ALTER TABLE IF EXISTS public.Immagine_BnB
    ADD FOREIGN KEY (CIR_BnB)
    REFERENCES public.BnB (CIR) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.Punto_di_Interesse
    ADD FOREIGN KEY (ID_Indirizzo)
    REFERENCES public.Indirizzo (ID_Indirizzo) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE SET NULL
    NOT VALID;


ALTER TABLE IF EXISTS public.Proprietà
    ADD FOREIGN KEY (Proprietario)
    REFERENCES public.Proprietario (Username) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
	DEFERRABLE INITIALLY DEFERRED
    NOT VALID;


ALTER TABLE IF EXISTS public.Proprietà
    ADD FOREIGN KEY (CIR_BnB)
    REFERENCES public.BnB (CIR) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
	DEFERRABLE INITIALLY DEFERRED
    NOT VALID;


/*POPOLAMENTO */

INSERT INTO Città (codice_postale, nome, paese) VALUES
('80033', 'Cicciano', 'Italia'),
('00100', 'Roma', 'Italia'),
('20121', 'Milano', 'Italia'),
('80100', 'Napoli', 'Italia'),
('10121', 'Torino', 'Italia'),
('90100', 'Palermo', 'Italia'),
('16121', 'Genova', 'Italia'),
('40121', 'Bologna', 'Italia'),
('50121', 'Firenze', 'Italia'),
('70121', 'Bari', 'Italia'),
('95121', 'Catania', 'Italia'),
('30121', 'Venezia', 'Italia'),
('37121', 'Verona', 'Italia'),
('98100', 'Messina', 'Italia'),
('35121', 'Padova', 'Italia'),
('34121', 'Trieste', 'Italia'),
('74121', 'Taranto', 'Italia'),
('25121', 'Brescia', 'Italia'),
('59100', 'Prato', 'Italia'),
('41121', 'Modena', 'Italia'),
('89121', 'Reggio Calabria', 'Italia'),
('42121', 'Reggio Emilia', 'Italia'),
('06121', 'Perugia', 'Italia'),
('48121', 'Ravenna', 'Italia'),
('57121', 'Livorno', 'Italia'),
('09100', 'Cagliari', 'Italia'),
('71121', 'Foggia', 'Italia'),
('47921', 'Rimini', 'Italia'),
('84121', 'Salerno', 'Italia'),
('44121', 'Ferrara', 'Italia'),
('07100', 'Sassari', 'Italia'),
('04100', 'Latina', 'Italia'),
('80014', 'Giugliano in Campania', 'Italia'),
('20900', 'Monza', 'Italia'),
('65121', 'Pescara', 'Italia'),
('24121', 'Bergamo', 'Italia'),
('47121', 'Forlì', 'Italia'),
('38121', 'Trento', 'Italia'),
('36121', 'Vicenza', 'Italia'),
('05100', 'Terni', 'Italia'),
('28100', 'Novara', 'Italia'),
('39100', 'Bolzano', 'Italia'),
('84083', 'Castel San Giorgio', 'Italia'),
('82100', 'Benevento', 'Italia'),
('80021', 'Afragola', 'Italia'),
('81100', 'Caserta', 'Italia'),
('80045', 'Pompei', 'Italia'),
('83100', 'Avellino', 'Italia'),
('84014', 'Nocera Inferiore', 'Italia'),
('84018', 'Scafati', 'Italia'),
('80056', 'Ercolano', 'Italia'),
('81031', 'Aversa', 'Italia'),
('80013', 'Casalnuovo di Napoli', 'Italia'),
('80040', 'Poggiomarino', 'Italia'),
('80039', 'Saviano', 'Italia'),
('80041', 'Boscoreale', 'Italia'),
('80046', 'San Giorgio a Cremano', 'Italia'),
('80049', 'Somma Vesuviana', 'Italia'),
('11511', 'Il Cairo', 'Egitto'),
('105 57', 'Atene', 'Grecia'),
('1012 JS', 'Amsterdam', 'Paesi Bassi'),
('D02', 'Dublino', 'Irlanda'),
('28001', 'Madrid', 'Spagna'),
('10110', 'Bangkok', 'Tailandia'),
('111 20', 'Stoccolma', 'Svezia'),
('00-001', 'Varsavia', 'Polonia'),
('1202', 'Ginevra', 'Svizzera'),
('0157', 'Oslo', 'Norvegia'),
('110001', 'New Delhi', 'India'),
('04508', 'Seoul', 'Corea del Sud'),
('LIMA 11', 'Lima', 'Perù'),
('8320000', 'Santiago', 'Cile'),
('8001', 'Città del Capo', 'Sudafrica'),
('C1002', 'Buenos Aires', 'Argentina'),
('1000-001', 'Lisbona', 'Portogallo'),
('G1 1XQ', 'Glasgow', 'Regno Unito'),
('1010', 'Vienna', 'Austria'),
('1052', 'Budapest', 'Ungheria'),
('1000', 'Bruxelles', 'Belgio'),
('00120', 'Città del Vaticano', 'Città del Vaticano'),
('6011', 'Wellington', 'Nuova Zelanda'),
('00000', 'Dubai', 'Emirati Arabi Uniti'),
('01000-000', 'San Paolo', 'Brasile'),
('11564', 'Riyad', 'Arabia Saudita'),
('13001', 'Città del Kuwait', 'Kuwait'),
('1019', 'Lussemburgo', 'Lussemburgo'),
('190000', 'San Pietroburgo', 'Russia'),
('2000', 'Johannesburg', 'Sudafrica'),
('400001', 'Mumbai', 'India'),
('200000', 'Shanghai', 'Cina'),
('20250', 'Casablanca', 'Marocco'),
('110 00', 'Praga', 'Repubblica Ceca'),
('030167', 'Bucarest', 'Romania'),
('K1P 1J1', 'Ottawa', 'Canada');


INSERT INTO indirizzo (id_indirizzo, Codice_Postale_città, tipo_infrastruttura, intestazione_infrastruttura, numero_civico)
VALUES
  (1000000001, '80033', 'Via', 'Tavernanova', 19),
  (1000000002, '80033', 'Via', 'della Vittoria', 1),
  (1000000003, '00100', 'Piazza', 'Garibaldi', 2),
  (1000000004, '20121', 'Corso', 'Italia', 3),
  (1000000005, '80100', 'Via', 'Milano', 4),
  (1000000006, '10121', 'Piazza', 'San Pietro', 5),
  (1000000007, '84121', 'Viale', 'Trastevere', 6),
  (1000000008, '16121', 'Largo', 'Argentina', 7),
  (1000000009, '40121', 'Piazza', 'Navona', 8),
  (1000000010, '50121', 'Via', 'Veneto', 9),
  (1000000011, '70121', 'Corso', 'Vittorio Emanuele II', 10),
  (1000000012, '95121', 'Viale', 'dei Fori Imperiali', 11),
  (1000000013, '30121', 'Piazza', 'del Popolo', 12),
  (1000000014, '37121', 'Via', 'Appia Antica', 13),
  (1000000015, '84121', 'Viale', 'Tiburtina', 14),
  (1000000016, '35121', 'Piazza', 'Barberini', 15),
  (1000000017, '34121', 'Corso', 'del Rinascimento', 16),
  (1000000018, '74121', 'Via', 'Cavour', 17),
  (1000000019, '25121', 'Viale', 'Aventino', 18),
  (1000000020, '59100', 'Piazza', 'di Spagna', 19),
  (1000000021, '41121', 'Corso', 'Garibaldi', 20),
  (1000000022, '89121', 'Via', 'Dante Alighieri', 21),
  (1000000023, '42121', 'Piazza', 'Duomo', 22),
  (1000000024, '84121', 'Viale', 'Sannio', 23),
  (1000000025, '48121', 'Corso', 'Sempione', 24),
  (1000000026, '57121', 'Via', 'Liguria', 25),
  (1000000027, '84121', 'Piazza', 'Italia', 26),
  (1000000028, '71121', 'Viale', 'Mazzini', 27),
  (1000000029, '47921', 'Corso', 'Venezia', 28),
  (1000000030, '84121', 'Piazza', 'dei Martiri', 29),
  (1000000031, '44121', 'Via', 'Garibaldi', 30),
  (1000000032, '07100', 'Viale', 'Capodimonte', 31),
  (1000000033, '04100', 'Corso', 'Vittorio Emanuele', 32),
  (1000000034, '80014', 'Via', 'Napoli', 33),
  (1000000035, '20900', 'Piazza', 'della Repubblica', 34),
  (1000000036, '24121', 'Corso', 'Vittorio Emanuele II', 36),
  (1000000037, '47121', 'Piazza', 'Cavour', 37),
  (1000000038, '38121', 'Via', 'Mazzini', 38),
  (1000000039, '36121', 'Viale', 'Kennedy', 39),
  (1000000040, '05100', 'Corso', 'Vittorio Emanuele', 40),
  (1000000041, '28100', 'Via', 'Roma', 41),
  (1000000042, '82100', 'Via', 'Roma', 10),
  (1000000043, '80021', 'Viale', 'degli Ulivi', 5),
  (1000000044, '81100', 'Corso', 'Italia', 15),
  (1000000045, '80045', 'Via', 'Mazzini', 20),
  (1000000046, '83100', 'Piazza', 'Garibaldi', 30),
  (1000000047, '84014', 'Via', 'San Francesco', 25),
  (1000000048, '84018', 'Viale', 'delle Palme', 12),
  (1000000049, '80056', 'Via', 'Marconi', 8),
  (1000000050, '81031', 'Corso', 'Umberto I', 42),
  (1000000051, '80013', 'Piazza', 'Matteotti', 18),
  (1000000052, '80040', 'Via', 'Napoli', 6),
  (1000000053, '80039', 'Viale', 'Kennedy', 22),
  (1000000054, '84121', 'Corso', 'Vittorio Emanuele', 14),
  (1000000055, '80046', 'Piazza', 'del Municipio', 11),
  (1000000056, '84121', 'Via', 'Dante Alighieri', 36),
  (1000000057, '84083', 'Via', 'Domenico Alfieri', 19),
  (1000000058, '84083', 'Via', 'Stradone', 19);

start transaction;

INSERT INTO allergia_o_intolleranza_cliente
VALUES ('Lattosio', 'clientuser1'),
       ('Glutine', 'clientuser2'),
       ('Arachidi', 'clientuser3'),
       ('Pesce', 'clientuser5'),
       ('Crostacei', 'clientuser6'),
       ('Soia', 'clientuser7'),
       ('Uova', 'clientuser8'),
       ('Semi di sesamo', 'clientuser9'),
       ('Senape', 'clientuser10'),
       ('Lievito', 'clientuser11'),
       ('Salsa di soia', 'clientuser15'),
       ('Caffè', 'clientuser16'),
       ('Zucchero', 'clientuser17'),
       ('Carne rossa', 'clientuser18'),
       ('Lievito di birra', 'clientuser20');
	   
INSERT INTO allergia_o_intolleranza_cliente (cliente)
VALUES ('clientuser4'),
       ('clientuser12'),
       ('clientuser13'),
       ('clientuser14'),
       ('clientuser19');


INSERT INTO allergia_o_intolleranza (Nome)
VALUES ('Lattosio'),
       ('Glutine'),
       ('Arachidi'),
       ('Pesce'),
       ('Crostacei'),
       ('Soia'),
       ('Uova'),
       ('Semi di sesamo'),
       ('Senape'),
	   ('Lievito'),
       ('Salsa di soia'),
       ('Caffè'),
       ('Zucchero'),
       ('Carne rossa'),
       ('Lievito di birra'),
       ('Nessuno');

INSERT INTO Cliente (Username, Nome, Cognome, Genere, Codice_fiscale, ID_Indirizzo_di_residenza, Codice_Postale_Città_di_nascita, Data_di_nascita, Indirizzo_e_mail, Telefono, Valuta, Contatto_di_emergenza)
VALUES ('clientuser1', 'Mario', 'Rossi', 'Uomo', 'RSSMRA80A01H123B', '1000000022', '80033', '1980-01-01', 'mario.rossi@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser2', 'Anna', 'Verdi', 'Donna', 'VRDANN80A01H456C', '1000000001', '00100', '1980-02-02', 'anna.verdi@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser3', 'John', 'Doe', 'Non binario', 'DOEJHN80A01H789D', '1000000002', '20121', '1980-03-03', 'john.doe@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser4', 'Maria', 'Bianchi', 'Donna', 'BNCMAR80A01H234E', '1000000003', '80100', '1980-04-04', 'maria.bianchi@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser5', 'Luigi', 'Verdi', 'Uomo', 'VRDLUI80A01H567F', '1000000004', '10121', '1980-05-05', 'luigi.verdi@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser6', 'Sara', 'Russo', 'Donna', 'RSSSAR80A01H890G', '1000000005', '90100', '1980-06-06', 'sara.russo@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser7', 'Marco', 'Gialli', 'Uomo', 'GLLMAR80A01H234H', '1000000044', '16121', '1980-07-07', 'marco.gialli@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser8', 'Laura', 'Neri', 'Donna', 'NRILAU80A01H567I', '1000000007', '40121', '1980-08-08', 'laura.neri@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser9', 'Giovanni', 'Rizzo', 'Uomo', 'RZZGIO80A01H890J', '1000000008', '190000', '1980-09-09', 'giovanni.rizzo@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser10', 'Paola', 'Rossini', 'Donna', 'RSSPAO80A01H234K', '1000000044', '70121', '1980-10-10', 'paola.rossini@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser11', 'Antonio', 'Galli', 'Uomo', 'GLLANT80A01H567L', '1000000010', '95121', '1980-11-11', 'antonio.galli@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser12', 'Francesca', 'Ricci', 'Donna', 'RCCFRA80A01H890M', '1000000011', '30121', '1980-12-12', 'francesca.ricci@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser13', 'Roberto', 'Marrone', 'Uomo', 'MRRROB80A01H234N', '1000000012', '37121', '1981-01-01', 'roberto.marrone@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser14', 'Chiara', 'Bianchi', 'Donna', 'BNCCHI80A01H567O', '1000000044', '98100', '1981-02-02', 'chiara.bianchi@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser15', 'Alessio', 'Verdi', 'Uomo', 'VRDALE80A01H890P', '1000000014', '190000', '1981-03-03', 'alessio.verdi@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser16', 'Silvia', 'Russo', 'Donna', 'RSSSIL80A01H234Q', '1000000015', '34121', '1981-04-04', 'silvia.russo@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser17', 'Luca', 'Gialli', 'Uomo', 'GLLGEN80A01H567R', '1000000044', '74121', '1981-05-05', 'luca.gialli@example.com', '1234567890', 'EUR', '1234567890'),
       ('clientuser18', 'Elisa', 'Neri', 'Donna', 'NRIELI80A01H890S', '1000000017', '25121', '1981-06-06', 'elisa.neri@example.com', '5555555555', 'GBP', '5555555555'),
       ('clientuser19', 'Andrea', 'Rizzo', 'Uomo', 'RZZAND80A01H234T', '1000000018', '59100', '1981-07-07', 'andrea.rizzo@example.com', '9876543210', 'USD', '9876543210'),
       ('clientuser20', 'Valentina', 'Rossini', 'Donna', 'RSSVAL80A01H567U', '1000000019', '41121', '1981-08-08', 'valentina.rossini@example.com', '1234567890', 'EUR', '1234567890');

INSERT INTO proprietà 
VALUES('pietroMartone','ABCDEFG123');

INSERT INTO proprietà
VALUES ('user456', 'GH56IJ78KL');

INSERT INTO proprietà
VALUES ('john.doe', 'MN90OP12QR');

INSERT INTO proprietà
VALUES ('jane_smith', 'ST34UV56WX');

INSERT INTO proprietà
VALUES ('user789', 'YZ78AB90CD');

INSERT INTO proprietà
VALUES ('pietroMartone', 'EF12GH34IJ');

INSERT INTO proprietà
VALUES ('mark_johnson', 'KL56MN78OP');

INSERT INTO proprietà
VALUES ('user101', 'QR90ST12UV');

INSERT INTO proprietà
VALUES ('user202', 'WX34YZ56AB');

INSERT INTO proprietà
VALUES ('mary_jones', 'CD78EF90GH');

INSERT INTO proprietà
VALUES ('username123', 'AB12CD34EF');

INSERT INTO proprietà
VALUES ('user303', 'AB12CD34EF');

INSERT INTO proprietà
VALUES ('user404', 'EF12GH34IJ');

INSERT INTO proprietà
VALUES ('steve12', 'KL56MN78OP');

INSERT INTO proprietà
VALUES ('user505', 'EF12GH34IJ');

INSERT INTO proprietà
VALUES ('user606', 'AB12CD34EF');

INSERT INTO proprietà
VALUES ('kate89', 'GH56IJ78KL');


INSERT INTO Proprietario (Username, Nome, Cognome, Genere, Codice_fiscale, ID_Indirizzo_di_residenza, ID_Indirizzo_legale, Codice_Postale_Città_di_nascita, Data_di_nascita, Indirizzo_e_mail, Telefono, Valuta, Partita_iva, Posta_elettronica_certificata, Breve_descrizione)
VALUES
  ('username123', 'Mario', 'Rossi', 'Uomo', 'RSSMRA80A01H123B', 1000000001, 1000000016, '00100', '1980-01-01', 'mario.rossi@example.com', '1234567890', 'EUR', '01234567890', 'pec@mario.rossi',null),
  ('user456', 'Giulia', 'Bianchi', 'Donna', 'BNCGLI80A01H456C', 1000000002, 1000000017, '20121', '1980-02-02', 'giulia.bianchi@example.com', '9876543211', 'USD', '09876543210', 'pec@giulia.bianchi', null),
  ('john.doe', 'John', 'Doe', 'Uomo', 'DOEJHN80A01H789D', 1000000003, 1000000018, '80100', '1980-03-03', 'john.doe@example.com', '5555555555', 'GBP', '07654321098', 'pec@john.doe', 'Breve descrizione del proprietario.'),
  ('jane_smith', 'Jane', 'Smith', 'Donna', 'SMIJAN80A01H456E', 1000000004, 1000000019, '50121', '1980-04-04', 'jane.smith@example.com', '1234567892', 'EUR', '01098765432', 'pec@jane.smith', 'Salve, mi chiamo Jane Smith e sono una importante figura di spicco del settore immobiliare italiano.'),
  ('user789', 'Marco', 'Ferrari', 'Uomo', 'FRRMRC80A01H789F', 1000000005, 1000000020, '10121', '1980-05-05', 'marco.ferrari@example.com', '9876543213', 'USD', '04567890123', 'pec@marco.ferrari', 'Buongiorno sono Marco Ferrari e sono proprietario di una struttura B&B a conduzione familiare'),
  ('pietroMartone', 'Pietro', 'Martiano', 'Uomo', 'MRTPTR02A24C259N', 1000000058, 1000000057, '84121', '2002-01-24', 'pietromartano@gmail.com', '+39 3920519606', 'EUR', '20012325512', 'pietromartano@pec.it', 'Salve, mi chiamo Pietro Martano e sono un gigante dell imprenditoria del Sud Italia.'),
  ('mark_johnson', 'Mark', 'Johnson', 'Uomo', 'JHNMRK80A01H456G', 1000000006, 1000000021, '40121', '1980-06-06', 'mark.johnson@example.com', '5555555557', 'GBP', '06789012345', 'pec@mark.johnson', null),
  ('user101', 'Laura', 'Russo', 'Donna', 'RSSLRA80A01H789H', 1000000007, 1000000022, '90100', '1980-07-07', 'laura.russo@example.com', '1234567894', 'EUR', '09876543219', 'pec@laura.russo', 'Salve, sono Laura Russo e sono un aspirante imprenditrice.'),
  ('user202', 'Andrea', 'Esposito', 'Uomo', 'ESPAAN80A01H456I', 1000000008, 1000000023, '16121', '1980-08-08', 'andrea.esposito@example.com', '9876543215', 'USD', '01234567891', 'pec@andrea.esposito', 'Salve, sono Andrea Esposito. Posseggo un infrastruttura adibita al ristoro a conduzione familiare.'),
  ('mary_jones', 'Mary', 'Jones', 'Non binario', 'JNSMAR80A01H789J', 1000000009, 1000000024, '37121', '1980-09-09', 'mary.jones@example.com', '5555555559', 'GBP', '09876543217', 'pec@mary.jones', null),
  ('user303', 'Giovanni', 'Ricci', 'Uomo', 'RCCGNN80A01H456K', 1000000010, 1000000025, '10121', '1980-10-10', 'giovanni.ricci@example.com', '1234567896', 'EUR', '04567890129', 'pec@giovanni.ricci', 'Buongiorno sono Giovanni Ricci e adoro il giardinaggio.'),
  ('user404', 'Emily', 'Brown', 'Donna', 'BROEMI80A01H789L', 1000000011, 1000000026, '50121', '1980-11-11', 'emily.brown@example.com', '9876543217', 'USD', '01234567892', 'pec@emily.brown', 'Salve, sono Emily Brown e vengo da molto lontano.'),
  ('steve12', 'Steve', 'Miller', 'Preferisco non dirlo', 'MILSTE80A01H456M', 1000000012, 1000000013, '20121', '1980-12-12', 'steve.miller@example.com', '5555555561', 'GBP', '09876543215', 'pec@steve.miller', null),
  ('user505', 'Laura', 'Anderson', 'Donna', 'ANDLAU80A01H789N', 1000000013, 1000000028, '00100', '1980-01-13', 'laura.anderson@example.com', '1234567898', 'EUR', '04567890137', 'pec@laura.anderson', 'Buongiorno sono Laura Anderson.'),
  ('user606', 'Thomas', 'Moore', 'Uomo', 'MOOTHO80A01H456O', 1000000014, 1000000029, '80100', '1980-02-14', 'thomas.moore@example.com', '9876543219', 'USD', '01234567893', 'pec@thomas.moore', 'Buongiorno, mi chiamo Thomas Moore.'),
  ('kate89', 'Kate', 'Wilson', 'Donna', 'WILKAT80A01H789P', 1000000015, 1000000030, '90100', '1980-03-15', 'kate.wilson@example.com', '5555555563', 'GBP', '09876543212', 'pec@kate.wilson', 'Breve descrizione del proprietario.');

INSERT INTO bnb (CIR, nome,ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('AB12CD34EF', 'B&B Happy Stay', '1000000005', '111111111', 4, 2, '12-12-2022', '14:00', '11:00', 'Un luogo felice per il tuo soggiorno, con camere confortevoli e servizio eccellente.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('GH56IJ78KL', 'B&B Cozy Cottage', '1000000007', '222222222', 2, 2, '10-01-2022', '15:00', '10:00', 'Un grazioso cottage dove sentirsi come a casa, con un atmosfera accogliente e servizi moderni.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('MN90OP12QR', 'B&B Serene Retreat', '1000000015', '333333333', 5, 3, '11-02-2021', '12:00', '09:00', 'Un rifugio sereno immerso nella natura, con camere eleganti e una splendida vista sul paesaggio.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('ST34UV56WX', 'B&B Sunshine Villa', '1000000024', '444444444', 3, 3, '10-05-2023', '13:00', '11:30', 'Una villa soleggiata con un giardino rigoglioso, stanze luminose e un atmosfera rilassante.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('YZ78AB90CD', 'B&B Charming Haven', '1000000027', '555555555', 6, 2, '08-05-2022', '14:30', '11:00', 'Un incantevole rifugio con camere eleganti, servizio attento e una posizione centrale.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('EF12GH34IJ', 'B&B Tranquil Oasis', '1000000047', '666666666', 4, 0, '01-01-2021', '13:00', '10:30', 'Un oasi tranquilla dove rigenerarsi, con camere confortevoli e un atmosfera pacifica.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('KL56MN78OP', 'B&B Vintage Charm', '1000000048', '777777777', 5, 0, '09-02-2023', '15:00', '11:00', 'Un incantevole rifugio con un tocco vintage, camere affascinanti e una posizione centrale.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('QR90ST12UV', 'B&B Sea Breeze', '1000000050', '888888888', 3, 2, '03-03-2022', '14:00', '10:30', 'Goditi la brezza marina in questo B&B accogliente, a pochi passi dalla spiaggia.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('WX34YZ56AB', 'B&B Rustic Retreat', '1000000051', '999999999', 6, 0, '01-04-2019', '12:00', '09:30', 'Un rifugio rustico immerso nella natura, con camere caratteristiche e un atmosfera accogliente.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('CD78EF90GH', 'B&B Urban Chic', '1000000052', '101010101', 4, 1, '04-04-2018', '13:00', '10:00', 'Un B&B dallo stile urbano ed elegante, con camere moderne e una posizione strategica.');

INSERT INTO bnb (CIR, nome, ID_Indirizzo, telefono, numero_di_stanze, numero_di_recensioni, anno_di_iscrizione, orario_check_in, orario_check_out, breve_descrizione)
VALUES ('ABCDEFG123', 'I milord', '1000000057', '101010101', 4, 1, '23-09-2018', '16:00', '9:00', 'Un B&B dallo stile urbano ed elegante, con camere moderne e una posizione strategica.');
 

commit work;
INSERT INTO fine_validità (data_pubblicazione, data_fine_validità)
VALUES 
('2020-10-12', '2023-10-12'),
('2023-02-09', '2026-02-09'),
('2020-10-29', '2023-10-29'),
('2020-07-19', '2023-07-19'),
('2021-06-11', '2024-06-11'),
('2018-09-20', '2021-09-20'),
('2020-12-09', '2023-12-09'),
('2022-06-09', '2025-06-09'),
('2023-06-09', '2026-06-09'),
('2019-02-10', '2022-02-10'),
('2021-06-19', '2024-06-19'),
('2018-08-19', '2021-08-19'),
('2021-03-23', '2024-03-23'),
('2019-05-29', '2022-05-29'),
('2022-09-09', '2025-09-09'),
('2022-06-18', '2025-06-18');

INSERT INTO recensione (id_recensione, autore_recensione, CIR_bnb, data_pubblicazione, data_inizio_pernottamento, data_fine_pernottamento, testo_della_recensione, visibilità)
VALUES 
(1000000001, 'clientuser2', 'GH56IJ78KL', '2020-10-12', '2020-10-09', '2020-10-11', 'Il B&B Cozy Cottage in cui ho soggiornato si trova nel cuore della città, regalando un atmosfera incantevole e romantica. Le camere spaziose e arredate con gusto offrono comfort e relax, mentre il personale attento e disponibile garantisce un esperienza ospitale e accogliente. Consiglio vivamente questa struttura a chiunque cerchi un rifugio incantevole e un servizio impeccabile durante il soggiorno.', true),
(1000000002, 'clientuser2', 'MN90OP12QR', '2023-02-09', '2023-02-02', '2023-02-07', 'Il B&B Serene Retreat è un esperienza indimenticabile, grazie alle camere elegantemente arredate e dotate di balcone privato.Il personale cortese e attento si prende cura di ogni dettaglio, garantendo un servizio impeccabile, mentre consiglia le migliori attrazioni locali.', true),
(1000000003, 'clientuser4', 'ST34UV56WX', '2020-07-19', '2020-07-10', '2020-07-18', 'Il B&B Sunshine Villa è un oasi di tranquillità immersa nella natura. Le camere spaziose e luminose offrono un ambiente accogliente e rilassante. Il personale cordiale e disponibile si occupa di ogni esigenza degli ospiti, garantendo un servizio impeccabile. Consiglio vivamente questa struttura a chiunque desideri una fuga rigenerante lontano dal caos della città.', true),
(1000000004, 'clientuser5', 'YZ78AB90CD', '2021-06-11', '2021-06-09', '2021-06-10', 'Il B&B Charming Haven è situato nel cuore del centro storico, offrendo un esperienza autentica. Le camere sono elegantemente arredate, creando un atmosfera accogliente. Il personale cortese e premuroso si assicura di soddisfare ogni esigenza degli ospiti, offrendo un servizio impeccabile.', true),
(1000000005, 'clientuser6', 'GH56IJ78KL', '2018-09-20', '2018-09-15', '2018-09-18', 'Il B&B Cozy Cottage è il luogo ideale per una vacanza al mare posto a pochi passi dalla spiaggia. Le camere sono luminose e spaziose e offrono una vista panoramica sull oceano. La colazione servita sulla terrazza è un momento di puro piacere con una varietà di prodotti freschi e genuini. Lo staff amichevole e premuroso si assicura che gli ospiti si sentano come a casa durante il loro soggiorno.', False),
(1000000006, 'clientuser7', 'MN90OP12QR', '2020-12-09', '2020-12-05', '2020-12-08', 'Il B&B Serene Retreat è un vero paradiso per gli amanti della natura. Le camere non sono molto spaziose e il bagno è molto piccolo. La colazione biologica a base di prodotti locali è un vero piacere per il palato. Lo staff attento e disponibile rende il soggiorno un esperienza indimenticabile.', true),
(1000000007, 'clientuser8', 'QR90ST12UV', '2022-06-09', '2022-06-05', '2022-06-07', 'Il soggiorno presso il B&B La Torre è stato un inferno. Le camere erano tutte sporche e il letto era molto scomodo. Il proprietario è stato molto scortese. La piscina era inutilizzabile e in condizioni pietrose. Sconsiglio vivamento questo B&B.', true),
(1000000008, 'clientuser9', 'ST34UV56WX', '2020-10-29', '2020-10-20', '2020-10-25', 'Il B&B Sunshine Villa è un oasi di pace e tranquillità immersa nel verde delle colline. Le camere sono accoglienti e ben arredate e offrono una vista panoramica sulla valle circostante. La colazione fatta in casa con prodotti locali è una vera delizia, mentre lo staff premuroso si assicura che ogni dettaglio sia curato.Consiglio vivamente il soggiorno a chi cerca un rifugio nella natura.', true),
(1000000009, 'clientuser10', 'CD78EF90GH', '2019-02-10', '2019-02-05', '2019-02-09', 'Il B&B La Piazza è il punto di partenza ideale per esplorare le attrazioni locali. Le camere sono grandi, ma poco organizzate. Il bagno non è molto spazioso e manca il bidet. La colazione continentale servita nella graziosa sala comune è un ottimo modo per iniziare la giornata. Lo staff cordiale e disponibile rende il soggiorno un esperienza piacevole e senza problemi.', False),
(1000000010, 'clientuser11', 'AB12CD34EF', '2022-09-09', '2022-09-01', '2022-09-06', 'Il B&B Il Nido mi ha lasciata con molti dubbi. Le camere sono decorate con gusto e sono dotate di caminetto, ma la pulizia lascia molto a desiderare. Il fatto che sia vicino al mare lo rende molto interessante, ma non ci sono servizi spiaggia inclusi. Lo staff è premuroso e attento.', true),
(1000000011, 'clientuser12', 'MN90OP12QR', '2021-06-19', '2021-06-15', '2021-06-18', 'Il B&B Serene Retreat offre una vista spettacolare sulla città e sul mare. Le camere sono moderne e ben arredate e offrono comfort e stile contemporaneo. La colazione a buffet è ricca e varia. Il personale cortese e professionale si preoccupa di garantire un esperienza piacevole e senza problemi.', true),
(1000000012, 'clientuser13', 'ST34UV56WX', '2018-08-19', '2018-08-19', '2018-08-19', 'Il B&B Sunshine Villa è un rifugio tranquillo e raffinato nel cuore della città. Le camere sono eleganti e ben arredate, ma mancano alcuni servizi come la televisione. Il balcone offre una vista mozzafiato sui giardini circostanti. La colazione a la carte è una delizia per il palato con una selezione di piatti gourmet preparati con ingredienti freschi e di alta qualità. Il personale attento e cortese si assicura che ogni desiderio degli ospiti sia soddisfatto durante il loro soggiorno.', False),
(1000000013, 'clientuser14', 'AB12CD34EF', '2021-03-23', '2021-03-15', '2021-03-20', 'Il B&B Le Cascate è un vero paradiso per gli amanti del trekking e dell avventura. Le camere non sono molto spaziose e il bagno è molto piccolo. La colazione a base di prodotti locali è un piacere autentico per il palato. Lo staff caloroso e ospitale si assicura che gli ospiti si sentano come a casa.', True),
(1000000014, 'clientuser15', 'YZ78AB90CD', '2019-05-29', '2019-05-19', '2019-05-28', 'L esperienza al B&B Charming Haven è stata un incubo. Le camere erano tutte sporche e il letto era molto scomodo. Non erano presenti finestre e l aria condizionata non funzionava. La colazione non offriva cibo per intolleranti al glutine.', False),
(1000000015, 'clientuser16', 'QR90ST12UV', '2022-09-09', '2023-03-10', '2022-09-07', 'Il B&B La Bellezza è un mix perfetto di stile contemporaneo e charme tradizionale. Le camere sono elegantemente arredate e dotate di servizi moderni. La colazione servita al mattino è un piacere per il palato. Il personale cortese e attento si preoccupa di garantire un soggiorno indimenticabile.', true),
(1000000000, 'clientuser1',  'ABCDEFG123', '2022-06-18', '2022-06-16', '2022-06-17', 'Il B&B I Milord in cui ho soggiornato si trova nel cuore della città. La struttura esterna non è ben curata, ma le camere interne sono pulite e offrono i servizi minimi. Il proprietario non è stato molto cortese.',true);

INSERT INTO valutazione VALUES
('Il B&B Cozy Cottage in cui ho soggiornato si trova nel cuore della città','0.9','Posizione'),
('regalando un atmosfera incantevole e romantica','1.0','Atmosfera'),
('Le camere spaziose e arredate con gusto offrono comfort e relax','0.8','Camera'),
('mentre il personale attento e disponibile garantisce un esperienza ospitale e accogliente','0.8','Personale'),
('Consiglio vivamente questa struttura a chiunque cerchi un rifugio incantevole','0.9','Consiglio'),
('un servizio durante il soggiorno è impeccabile','0.9','Servizio'),

('Il B&B Serene Retreat è un esperienza indimenticabile','1.0','Generale'),
('grazie alle camere elegantemente arredate e dotate di balcone privato','0.9','Camera'),
('Il personale cortese e attento, si prende cura di ogni dettaglio','0.8','Personale'),
('garantendo un servizio impeccabile','0.9','Servizio'),
('mentre consiglia le migliori attrazioni locali','0.9','Punti di Interesse'),

('Il B&B Sunshine Villa è un oasi di tranquillità immersa nella natura','0.9','Posizione'),
('Le camere spaziose e luminose offrono un ambiente accogliente e rilassante','0.8','Camere'),
('Il personale cordiale e disponibile si occupa di ogni esigenza degli ospiti','0.8','Personale'),
('Consiglio vivamente questa struttura a chiunque desideri una fuga rigenerante lontano dal caos della città','0.9','Consiglio'),

('Il B&B Cgarminh Haven è situato nel cuore del centro storico','0.9','Posizione'),
('offrendo un esperienza autentica','0.9','Generale'),
('Le camere sono elegantemente arredate','0.9','Camera'),
('creando un atmosfera accogliente','0.9','Atmosfera'),
('Il personale cortese e premuroso si assicura di soddisfare ogni esigenza degli ospiti','0.8','Personale'),
('offrendo un servizio impeccabile','0.9','Servizio'),

('Il B&B Cozy Cottage è il luogo ideale per una vacanza al mare posto a pochi passi dalla spiaggia','0.8','Posizione'),
('Le camere luminose e spaziose offrono una vista panoramica sull oceano','0.8','Camera'),
('La colazione servita sulla terrazza è un momento di puro piacere con una varietà di prodotti freschi e genuini','0.9','Colazione'),
('Lo staff amichevole e premuroso si assicura che gli ospiti si sentano come a casa durante il loro soggiorno','0.8','Personale'),

('Il B&B Serene Retreat è un vero paradiso per gli amanti della natura','0.9','Posizione'),
('Le camere non sono molto spaziose','0.6','Camera'),
('il bagno è molto piccolo','0.4','Bagno'),
('La colazione biologica a base di prodotti locali è un vero piacere per il palato','0.8','Colazione'),
('Lo staff attento e disponibile rende il soggiorno un esperienza indimenticabile','0.9','Personale'),

('Il soggiorno presso il B&B La Torre è stato un inferno','0.2','Generale'),
('Le camere erano tutte sporche','0.4','Camera'),
('il letto era molto scomodo','0.4','Servizio interno'),
('Il proprietario è stato molto scortese','0.2','Proprietario'),
('La piscina era inutilizzabile e in condizioni pietrose','0.2','Servizio aggiuntivo'),
('Sconsiglio vivamento questo B&B','0.2','Consiglio'),

('Il B&B Sunshine Villa è un oasi di pace e tranquillità immersa nel verde delle colline','0.9','Generale'),
('Le camere accoglienti e ben arredate offrono una vista panoramica sulla valle circostante','0.8','Camera'),
('La colazione fatta in casa con prodotti locali è una vera delizia','0.9','Colazione'),
('lo staff premuroso si assicura che ogni dettaglio sia curato','0.8','Personale'),
('Consiglio vivamente il soggiorno a chi cerca un rifugio nella natura','0.9','Consiglio'),

('Il B&B La Piazza è il punto di partenza ideale per esplorare le attrazioni locali','0.8','Posizione'),
('Le camere sono grandi','0.8','Camera'),
('poco organizzate','0.4','Organizzazione'),
('Il bagno non è molto spazioso','0.6','Bagno'),
('manca il bidet','0.4','Servizio interno'),
('La colazione continentale servita nella graziosa sala comune è un ottimo modo per iniziare la giornata','0.9','Colazione'),
('Lo staff cordiale e disponibile rende il soggiorno un esperienza piacevole e senza problemi','0.8','Personale'),

('Il B&B Il Nido mi ha lasciata con molti dubbi','0.6','Generale'),
('Le camere sono decorate con gusto','0.8','Camera'),
('sono dotate di caminetto','0.9','Servizio interno'),
('la pulizia lascia molto a desiderare','0.6','Pulizia'),
('Il fatto che sia vicino al mare lo rende molto interessante','0.8','Posizione'),
('non ci sono servizi spiaggia inclusi','0.6','Servizio aggiuntivo'),
('Lo staff è premuroso e attento','0.8','Personale'),

('Il B&B Serene Retreat offre una vista spettacolare sulla città e sul mare','0.9','Posizione'),
('Le camere moderne e ben arredate offrono comfort e stile contemporaneo','0.9','Camera'),
('La colazione a buffet è ricca e varia','0.8','Colazione'),
('Il personale cortese e professionale si preoccupa di garantire un esperienza piacevole e senza problemi','0.8','Personale'),

('Il B&B Sunshine Villa è un rifugio tranquillo e raffinato nel cuore della città','0.9','Posizione'),
('Le camere sono eleganti e ben arredate','0.9','Camera'),
('mancano alcuni servizi come la televisione','0.6','Servizio interno'),
('Il balcone offre una vista mozzafiato sui giardini circostanti','0.9','Vista'),
('La colazione a la carte è una delizia per il palato con una selezione di piatti gourmet preparati con ingredienti freschi e di alta qualità','1.0','Colazione'),
('Il personale attento e cortese si assicura che ogni desiderio degli ospiti sia soddisfatto durante il loro soggiorno','0.8','Personale'),

('Il B&B Le Cascate è un vero paradiso per gli amanti del trekking e dell avventura','0.9','Generale'),
('La colazione a base di prodotti locali è un piacere autentico per il palato','0.9','Colazione'),
('Lo staff caloroso e ospitale si assicura che gli ospiti si sentano come a casa','0.8','Personale'),

('L esperienza al B&B Charming Haven è stata un incubo','0.2','Generale'),
('Non erano presenti finestre','0.2','Camera'),
('l aria condizionata non funzionava','0.2','Servizio interno'),
('La colazione non offriva cibo per intolleranti al glutine','0.4','Colazione'),

('Il B&B La Bellezza è un mix perfetto di stile contemporaneo e charme tradizionale','0.9','Generale'),
('dotate di servizi moderni','0.9','Servizio interno'),
('La colazione servita al mattino è un piacere per il palato','0.8','Colazione'),
('Il personale cortese e attento si preoccupa di garantire un soggiorno indimenticabile','0.8','Personale'),

('Il B&B I Milord in cui ho soggiornato si trova nel cuore della città','0.8','Posizione'),
('La struttura esterna non è ben curata','0.4','Struttura'),
('le camere interne sono pulite','0.6','Camera'),
('offrono i servizi minimi','0.6','Servizio interno'),
('Il proprietario non è stato molto cortese','0.4','Proprietario');


INSERT INTO proposizione_id VALUES

('P1','Il B&B Cozy Cottage in cui ho soggiornato si trova nel cuore della città'),
('P2','regalando un atmosfera incantevole e romantica'),
('P3','Le camere spaziose e arredate con gusto offrono comfort e relax'),
('P4','mentre il personale attento e disponibile garantisce un esperienza ospitale e accogliente'),
('P5','Consiglio vivamente questa struttura a chiunque cerchi un rifugio incantevole'),
('P6','un servizio durante il soggiorno è impeccabile'),

('P7','Il B&B Serene Retreat è un esperienza indimenticabile'),
('P8','grazie alle camere elegantemente arredate e dotate di balcone privato'),
('P9','Il personale cortese e attento, si prende cura di ogni dettaglio'),
('P10','garantendo un servizio impeccabile'),
('P11','mentre consiglia le migliori attrazioni locali'),

('P12','Il B&B Sunshine Villa è un oasi di tranquillità immersa nella natura'),
('P13','Le camere spaziose e luminose offrono un ambiente accogliente e rilassante'),
('P14','Il personale cordiale e disponibile si occupa di ogni esigenza degli ospiti'),
('P15','Consiglio vivamente questa struttura a chiunque desideri una fuga rigenerante lontano dal caos della città'),

('P16','Il B&B Cgarminh Haven è situato nel cuore del centro storico'),
('P17','offrendo un esperienza autentica'),
('P18','Le camere sono elegantemente arredate'),
('P19','creando un atmosfera accogliente'),
('P20','Il personale cortese e premuroso si assicura di soddisfare ogni esigenza degli ospiti'),
('P21','offrendo un servizio impeccabile'),

('P22','Il B&B Cozy Cottage è il luogo ideale per una vacanza al mare posto a pochi passi dalla spiaggia'),
('P23','Le camere luminose e spaziose offrono una vista panoramica sull oceano'),
('P24','La colazione servita sulla terrazza è un momento di puro piacere con una varietà di prodotti freschi e genuini'),
('P25','Lo staff amichevole e premuroso si assicura che gli ospiti si sentano come a casa durante il loro soggiorno'),

('P26','Il B&B Serene Retreat è un vero paradiso per gli amanti della natura'),
('P27','Le camere non sono molto spaziose'),
('P28','il bagno è molto piccolo'),
('P29','La colazione biologica a base di prodotti locali è un vero piacere per il palato'),
('P30','Lo staff attento e disponibile rende il soggiorno un esperienza indimenticabile'),

('P31','Il soggiorno presso il B&B La Torre è stato un inferno'),
('P32','Le camere erano tutte sporche'),
('P33','il letto era molto scomodo'),
('P34','Il proprietario è stato molto scortese'),
('P35','La piscina era inutilizzabile e in condizioni pietrose'),
('P36','Sconsiglio vivamento questo B&B'),

('P37','Il B&B Sunshine Villa è un oasi di pace e tranquillità immersa nel verde delle colline'),
('P38','Le camere accoglienti e ben arredate offrono una vista panoramica sulla valle circostante'),
('P39','La colazione fatta in casa con prodotti locali è una vera delizia'),
('P40','lo staff premuroso si assicura che ogni dettaglio sia curato'),
('P41','Consiglio vivamente il soggiorno a chi cerca un rifugio nella natura'),

('P42','Il B&B La Piazza è il punto di partenza ideale per esplorare le attrazioni locali'),
('P43','Le camere sono grandi'),
('P44','poco organizzate'),
('P45','Il bagno non è molto spazioso'),
('P46','manca il bidet'),
('P47','La colazione continentale servita nella graziosa sala comune è un ottimo modo per iniziare la giornata'),
('P48','Lo staff cordiale e disponibile rende il soggiorno un esperienza piacevole e senza problemi'),

('P49','Il B&B Il Nido mi ha lasciata con molti dubbi'),
('P50','Le camere sono decorate con gusto'),
('P51','sono dotate di caminetto'),
('P52','la pulizia lascia molto a desiderare'),
('P53','Il fatto che sia vicino al mare lo rende molto interessante'),
('P54','non ci sono servizi spiaggia inclusi'),
('P55','Lo staff è premuroso e attento'),

('P56','Il B&B Serene Retreat offre una vista spettacolare sulla città e sul mare'),
('P57','Le camere moderne e ben arredate offrono comfort e stile contemporaneo'),
('P58','La colazione a buffet è ricca e varia'),
('P59','Il personale cortese e professionale si preoccupa di garantire un esperienza piacevole e senza problemi'),

('P60','Il B&B Sunshine Villa è un rifugio tranquillo e raffinato nel cuore della città'),
('P61','Le camere sono eleganti e ben arredate'),
('P62','mancano alcuni servizi come la televisione'),
('P63','Il balcone offre una vista mozzafiato sui giardini circostanti'),
('P64','La colazione a la carte è una delizia per il palato con una selezione di piatti gourmet preparati con ingredienti freschi e di alta qualità'),
('P65','Il personale attento e cortese si assicura che ogni desiderio degli ospiti sia soddisfatto durante il loro soggiorno'),

('P66','Il B&B Le Cascate è un vero paradiso per gli amanti del trekking e dell avventura'),
('P67','La colazione a base di prodotti locali è un piacere autentico per il palato'),
('P68','Lo staff caloroso e ospitale si assicura che gli ospiti si sentano come a casa'),

('P69','L esperienza al B&B Charming Haven è stata un incubo'),
('P70','Non erano presenti finestre'),
('P71','l aria condizionata non funzionava'),
('P72','La colazione non offriva cibo per intolleranti al glutine'),

('P73','Il B&B La Bellezza è un mix perfetto di stile contemporaneo e charme tradizionale'),
('P74','dotate di servizi moderni'),
('P75','La colazione servita al mattino è un piacere per il palato'),
('P76','Il personale cortese e attento si preoccupa di garantire un soggiorno indimenticabile'),

('P77','Il B&B I Milord in cui ho soggiornato si trova nel cuore della città'),
('P78','La struttura esterna non è ben curata'),
('P79','le camere interne sono pulite'),
('P80','offrono i servizi minimi'),
('P81','Il proprietario non è stato molto cortese');

INSERT INTO frase_complessa_id VALUES

('F1','Il B&B Cozy Cottage in cui ho soggiornato si trova nel cuore della città, regalando un atmosfera incantevole e romantica.'),
('F2','Le camere spaziose e arredate con gusto offrono comfort e relax, mentre il personale attento e disponibile garantisce un esperienza ospitale e accogliente.'),
('F3','Consiglio vivamente questa struttura a chiunque cerchi un rifugio incantevole e un servizio impeccabile durante il soggiorno.'),

('F4','Il B&B Serene Retreat è un esperienza indimenticabile, grazie alle camere elegantemente arredate e dotate di balcone privato.'),
('F5','Il personale cortese e attento si prende cura di ogni dettaglio, garantendo un servizio impeccabile, mentre consiglia le migliori attrazioni locali'),

('F6','Il B&B Sunshine Villa è un oasi di tranquillità immersa nella natura.'),
('F7','Le camere spaziose e luminose offrono un ambiente accogliente e rilassante.'),
('F8','Il personale cordiale e disponibile si occupa di ogni esigenza degli ospiti, garantendo un servizio impeccabile.'),
('F9','Consiglio vivamente questa struttura a chiunque desideri una fuga rigenerante lontano dal caos della città."'),

('F10','Il B&B Charminh Haven è situato nel cuore del centro storico, offrendo un esperienza autentica.'),
('F11','Le camere sono elegantemente arredate, creando un atmosfera accogliente.'),
('F12','Il personale cortese e premuroso si assicura di soddisfare ogni esigenza degli ospiti, offrendo un servizio impeccabile.'),

('F13', 'Il B&B Cozy Cottage è il luogo ideale per una vacanza al mare posto a pochi passi dalla spiaggia.'),
('F14','Le camere sono luminose e spaziose e offrono una vista panoramica sull oceano.'),
('F15','La colazione servita sulla terrazza è un momento di puro piacere con una varietà di prodotti freschi e genuini.'),
('F16','Lo staff amichevole e premuroso si assicura che gli ospiti si sentano come a casa durante il loro soggiorno.'),

('F17','Il B&B Serene Retreat è un vero paradiso per gli amanti della natura.'),
('F18','Le camere non sono molto spaziose e il bagno è molto piccolo.'),
('F19','La colazione biologica a base di prodotti locali è un vero piacere per il palato.'),
('F20','Lo staff attento e disponibile rende il soggiorno un esperienza indimenticabile.'),

('F21','Il soggiorno presso il B&B La Torre è stato un inferno.'),
('F22','Le camere erano tutte sporche e il letto era molto scomodo.'),
('F23','Il proprietario è stato molto scortese.'),
('F24','La piscina era inutilizzabile e in condizioni pietrose.'),
('F25','Sconsiglio vivamento questo B&B.'),

('F26','Il B&B Sunshine Villa è un oasi di pace e tranquillità immersa nel verde delle colline.'),
('F27','Le camere sono accoglienti e ben arredate e offrono una vista panoramica sulla valle circostante.'),
('F28','La colazione fatta in casa con prodotti locali è una vera delizia, mentre lo staff premuroso si assicura che ogni dettaglio sia curato.'),
('F29','Consiglio vivamente il soggiorno a chi cerca un rifugio nella natura.'),

('F30','Il B&B La Piazza è il punto di partenza ideale per esplorare le attrazioni locali.'),
('F31','Le camere sono grandi, ma poco organizzate.'),
('F32','Il bagno non è molto spazioso e manca il bidet.'),
('F33','La colazione continentale servita nella graziosa sala comune è un ottimo modo per iniziare la giornata.'),
('F34','Lo staff cordiale e disponibile rende il soggiorno un esperienza piacevole e senza problemi.'),

('F35','Il B&B Il Nido mi ha lasciata con molti dubbi.'),
('F36','Le camere sono decorate con gusto e sono dotate di caminetto, ma la pulizia lascia molto a desiderare.'),
('F37','Il fatto che sia vicino al mare lo rende molto interessante, ma non ci sono servizi spiaggia inclusi.'),
('F38','Lo staff è premuroso e attento.'),

('F39','Il B&B Serene Retreat offre una vista spettacolare sulla città e sul mare.'),
('F40','Le camere sono moderne e ben arredate e offrono comfort e stile contemporaneo.'),
('F41','La colazione a buffet è ricca e varia.'),
('F42','Il personale cortese e professionale si preoccupa di garantire un esperienza piacevole e senza problemi.'),

('F43','Il B&B Sunshine Villa è un rifugio tranquillo e raffinato nel cuore della città.'),
('F44','Le camere sono eleganti e ben arredate, ma mancano alcuni servizi come la televisione.'),
('F45','Il balcone offre una vista mozzafiato sui giardini circostanti.'),
('F46','La colazione a la carte è una delizia per il palato con una selezione di piatti gourmet preparati con ingredienti freschi e di alta qualità.'),
('F47','Il personale attento e cortese si assicura che ogni desiderio degli ospiti sia soddisfatto durante il loro soggiorno.'),

('F48','Il B&B Le Cascate è un vero paradiso per gli amanti del trekking e dell avventura.'),
('F49','La colazione a base di prodotti locali è un piacere autentico per il palato.'),
('F50','Lo staff caloroso e ospitale si assicura che gli ospiti si sentano come a casa.'),

('F51','L esperienza al B&B Charming Haven è stata un incubo.'),

('F52','Non erano presenti finestre e l aria condizionata non funzionava.'),
('F53','La colazione non offriva cibo per intolleranti al glutine.'),

('F54','Il B&B La Bellezza è un mix perfetto di stile contemporaneo e charme tradizionale.'),
('F55','Le camere sono elegantemente arredate e dotate di servizi moderni.'),
('F56','La colazione servita al mattino è un piacere per il palato.'),
('F57','Il personale cortese e attento si preoccupa di garantire un soggiorno indimenticabile.'),

('F58','Il B&B I Milord in cui ho soggiornato si trova nel cuore della città.'),
('F59','La struttura esterna non è ben curata, ma le camere interne sono pulite e offrono i servizi minimi.'),
('F60','Il proprietario non è stato molto cortese.');



INSERT INTO frase_complessa VALUES
('1000000000','F58'),
('1000000000','F59'),
('1000000000','F60'),

('1000000001','F1'),
('1000000001','F2'),
('1000000001','F3'),

('1000000002','F4'),
('1000000002','F5'),

('1000000003','F6'),
('1000000003','F7'),
('1000000003','F8'),
('1000000003','F9'),

('1000000004','F10'),
('1000000004','F11'),
('1000000004','F12'),

('1000000005','F13'),
('1000000005','F14'),
('1000000005','F15'),
('1000000005','F16'),

('1000000006','F17'),
('1000000006','F18'),
('1000000006','F19'),
('1000000006','F20'),

('1000000007','F21'),
('1000000007','F22'),
('1000000007','F23'),
('1000000007','F24'),
('1000000007','F25'),

('1000000008','F26'),
('1000000008','F27'),
('1000000008','F28'),
('1000000008','F29'),

('1000000009','F30'),
('1000000009','F31'),
('1000000009','F32'),
('1000000009','F33'),
('1000000009','F34'),

('1000000010','F35'),
('1000000010','F36'),
('1000000010','F37'),
('1000000010','F38'),

('1000000011','F39'),
('1000000011','F40'),
('1000000011','F41'),
('1000000011','F42'),

('1000000012','F43'),
('1000000012','F44'),
('1000000012','F45'),
('1000000012','F46'),
('1000000012','F47'),

('1000000013','F48'),
('1000000013','F18'),
('1000000013','F49'),
('1000000013','F50'),

('1000000014','F51'),
('1000000014','F22'),
('1000000014','F52'),
('1000000014','F53'),

('1000000015','F54'),
('1000000015','F55'),
('1000000015','F56'),
('1000000015','F57');






INSERT INTO proposizione VALUES

('1000000001','F1','P1'),
('1000000001','F1','P2'),
('1000000001','F2','P3'),
('1000000001','F2','P4'),
('1000000001','F3','P5'),
('1000000001','F3','P6'),

('1000000002','F4','P7'),
('1000000002','F4','P8'),
('1000000002','F5','P9'),
('1000000002','F5','P10'),
('1000000002','F5','P11'),


('1000000003','F6','P12'),
('1000000003','F7','P13'),
('1000000003','F8','P14'),
('1000000003','F8','P10'),
('1000000003','F9','P15'),

('1000000004','F10','P16'),
('1000000004','F10','P17'),
('1000000004','F11','P18'),
('1000000004','F11','P19'),
('1000000004','F12','P20'),
('1000000004','F12','P21'),

('1000000005','F13','P22'),
('1000000005','F14','P23'),
('1000000005','F15','P24'),
('1000000005','F16','P25'),

('1000000006','F17','P26'),
('1000000006','F18','P27'),
('1000000006','F18','P28'),
('1000000006','F19','P29'),
('1000000006','F20','P30'),

('1000000007','F21','P31'),
('1000000007','F22','P32'),
('1000000007','F22','P33'),
('1000000007','F23','P34'),
('1000000007','F24','P35'),
('1000000007','F25','P36'),

('1000000008','F26','P37'),
('1000000008','F27','P38'),
('1000000008','F28','P39'),
('1000000008','F28','P40'),
('1000000008','F29','P41'),

('1000000009','F30','P42'),
('1000000009','F31','P43'),
('1000000009','F31','P44'),
('1000000009','F32','P45'),
('1000000009','F32','P46'),
('1000000009','F33','P47'),
('1000000009','F34','P48'),

('1000000010','F35','P49'),
('1000000010','F36','P50'),
('1000000010','F36','P51'),
('1000000010','F36','P52'),
('1000000010','F37','P53'),
('1000000010','F37','P54'),
('1000000010','F38','P55'),

('1000000011','F39','P56'),
('1000000011','F40','P57'),
('1000000011','F41','P58'),
('1000000011','F42','P59'),

('1000000012','F43','P60'),
('1000000012','F44','P61'),
('1000000012','F44','P62'),
('1000000012','F45','P63'),
('1000000012','F46','P64'),
('1000000012','F47','P65'),

('1000000013','F48','P66'),
('1000000013','F18','P28'),
('1000000013','F49','P67'),
('1000000013','F50','P68'),

('1000000014','F51','P69'),
('1000000014','F22','P32'),
('1000000014','F22','P33'),
('1000000014','F52','P70'),
('1000000014','F52','P71'),
('1000000014','F53','P72'),

('1000000015','F54','P73'),
('1000000015','F55','P18'),
('1000000015','F55','P74'),
('1000000015','F56','P75'),
('1000000015','F57','P76'),

('1000000000','F58','P77'),
('1000000000','F59','P78'),
('1000000000','F59','P79'),
('1000000000','F59','P80'),
('1000000000','F60','P81');



INSERT INTO lingue_parlate (lingua)
VALUES ('Inglese'),
       ('Francese'),
       ('Spagnolo'),
       ('Italiano'),
       ('Tedesco');

INSERT INTO lingua_proprietario (proprietario, lingua)
VALUES ('username123', 'Inglese'),
       ('user456', 'Francese'),
       ('john.doe', 'Spagnolo'),
       ('jane_smith', 'Italiano'),
       ('user789', 'Tedesco'),
       ('pietroMartone', 'Francese'),
       ('mark_johnson', 'Inglese'),
       ('user101', 'Spagnolo'),
       ('user202', 'Italiano'),
       ('mary_jones', 'Tedesco'),
       ('user303', 'Inglese'),
       ('user404', 'Francese'),
       ('steve12', 'Spagnolo'),
       ('user505', 'Italiano'),
       ('user606', 'Tedesco'),
       ('kate89', 'Inglese'),
	   ('username123', 'Italiano'),
       ('user456', 'Spagnolo'),
       ('john.doe', 'Italiano'),
       ('jane_smith', 'Inglese'),
       ('user789', 'Inglese'),
       ('pietroMartone', 'Italiano'),
       ('mark_johnson', 'Tedesco'),
       ('user101', 'Italiano'),
       ('user202', 'Inglese'),
       ('mary_jones', 'Francese'),
       ('user303', 'Tedesco'),
       ('user404', 'Italiano'),
       ('steve12', 'Tedesco'),
       ('user505', 'Tedesco'),
       ('user606', 'Italiano'),
       ('kate89', 'Tedesco');



INSERT INTO punto_di_interesse (id_indirizzo, nome, descrizione, categoria)VALUES 
	   ('1000000031', 'Piazza del Popolo', 'Bella piazza nel centro storico', 'Piazze'),
       ('1000000032', 'Colosseo', 'Antico anfiteatro romano', 'Monumenti'),
       ('1000000033', 'Fontana di Trevi', 'Famosa fontana di Roma', 'Attrazioni turistiche'),
       ('1000000034', 'Ponte di Rialto', 'Ponte storico di Venezia', 'Ponte'),
       ('1000000035', 'Cattedrale di Notre-Dame', 'Famosa cattedrale di Parigi', 'Chiese'),
       ('1000000036', 'Acropoli di Atene', 'Collina con antichi templi', 'Siti archeologici'),
       ('1000000037', 'Piazza San Marco', 'Principale piazza di Venezia', 'Piazze'),
       ('1000000038', 'Museo del Louvre', 'Famoso museo d arte di Parigi', 'Musei'),
       ('1000000039', 'Torre Eiffel', 'Iconica torre di Parigi', 'Monumenti'),
       ('1000000040', 'Sagrada Familia', 'Incompiuta basilica di Barcellona', 'Chiese');


INSERT INTO adiacenza (CIR_BnB, ID_indirizzo_punto_di_interesse, distanza)
VALUES ('AB12CD34EF', '1000000031', 3),
       ('GH56IJ78KL', '1000000032', 2),
       ('MN90OP12QR', '1000000033', 4),
       ('ST34UV56WX', '1000000034', 1),
       ('YZ78AB90CD', '1000000035', 2),
       ('EF12GH34IJ', '1000000036', 3),
       ('KL56MN78OP', '1000000037', 4),
       ('QR90ST12UV', '1000000038', 1),
       ('WX34YZ56AB', '1000000039', 3),
       ('CD78EF90GH', '1000000040', 2),
       ('ABCDEFG123', '1000000031', 4),
	   ('YZ78AB90CD', '1000000040', 3),
       ('EF12GH34IJ', '1000000039', 2),
       ('MN90OP12QR', '1000000038', 4),
       ('GH56IJ78KL', '1000000037', 1),
       ('AB12CD34EF', '1000000036', 2),
       ('KL56MN78OP', '1000000035', 3),
       ('WX34YZ56AB', '1000000034', 1),
       ('ST34UV56WX', '1000000033', 4),
       ('CD78EF90GH', '1000000032', 3),
       ('QR90ST12UV', '1000000031', 2),
       ('ABCDEFG123', '1000000040', 4);

INSERT INTO immagine_bnb (immagine, CIR_bnb)
VALUES (E'\\x0123456789ABCDEF', 'AB12CD34EF'),
       (E'\\xABCDEF0123456789', 'GH56IJ78KL'),
       (E'\\x0123456789ABCDEE', 'ABCDEFG123'),
	   (E'\\x0123456789ABCDEC', 'ABCDEFG123'),
       (E'\\x0123456789ABCDEA', 'ABCDEFG123');