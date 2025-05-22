/*QUERY AGGREGAZIONE E JOIN*/

SELECT CIR AS BnB, MAX(Punteggio_Sentiment) as Massima_Valutazione, MIN(Punteggio_Sentiment) as Minimo_Valutazione, AVG(Punteggio_Sentiment) as Media_Valutazione
FROM (((BnB 
JOIN Recensione AS R ON CIR = CIR_BnB) 
JOIN Proposizione AS P ON P.ID_Recensione = R.ID_Recensione) 
JOIN Proposizione_ID AS PID ON PID.ID_Proposizione = P.ID_Proposizione) 
JOIN Valutazione AS V ON PID.Testo_della_Proposizione = V.Testo_della_Proposizione
WHERE Tipo_Aspect = 'Camera'
GROUP BY CIR
HAVING AVG(Punteggio_Sentiment) > (SELECT AVG(Punteggio_Sentiment)
               FROM (Proposizione 
               JOIN Proposizione_ID ON Proposizione_ID.ID_Proposizione = Proposizione.ID_Proposizione) 
               JOIN Valutazione ON Proposizione_ID.Testo_della_Proposizione = Valutazione.Testo_della_Proposizione
               WHERE Tipo_Aspect = 'Camera')
ORDER BY Media_Valutazione DESC;

/*QUERY NIDIFICATA COMPLESSA*/

SELECT Username, Nome, Cognome, Allergia_o_Intolleranza
FROM Cliente as C JOIN Allergia_o_Intolleranza_Cliente ON (Cliente=C.Username)
WHERE EXISTS (
    SELECT *
    FROM Proprietario as P
    WHERE C.Codice_Fiscale = P.Codice_Fiscale AND (
		SELECT COUNT(*) 
		FROM Proprietà 
		WHERE P.Username=Proprietario)<3
)
AND (
    SELECT COUNT(*)
    FROM Recensione
    WHERE Autore_Recensione = C.Username
) < ALL (
    SELECT Numero_di_Recensioni
    FROM BnB as B
    WHERE EXISTS (
        SELECT *
        FROM Proprietà AS PRO
		WHERE B.CIR=PRO.CIR_Bnb AND PRO.Proprietario IN (
			SELECT Username
            FROM Proprietario 
            WHERE C.Codice_Fiscale = Proprietario.Codice_Fiscale 
		)
    )
);

/*QUERY INSIEMISTICA*/

SELECT Username, Città.Nome AS Città_di_Nascita, Data_di_nascita, Genere
FROM Cliente AS C
JOIN Città ON Codice_Postale_Città_di_Nascita = Codice_Postale
WHERE Paese = 'Italia' AND 
EXISTS (
	SELECT * 
	FROM Allergia_o_intolleranza_Cliente AS A 
	WHERE A.Cliente=C.Username AND A.Allergia_o_Intolleranza = 'Nessuno')
UNION
SELECT Username, Città.Nome AS Città_di_Nascita, Data_di_nascita, Genere
FROM Cliente
JOIN Città ON Codice_Postale_Città_di_Nascita = Codice_Postale
WHERE Paese <> 'Italia' and Cliente.ID_Indirizzo_di_Residenza IN (
	SELECT ID_Indirizzo  
	FROM Indirizzo 
	JOIN Città ON (Codice_Postale_Città = Codice_Postale) 
	WHERE Paese='Italia')
EXCEPT
SELECT Username, Città.Nome AS Città_di_Nascita, Data_di_nascita, Genere
FROM Cliente
JOIN Città ON Codice_Postale_Città_di_Nascita = Codice_Postale
WHERE NOT EXISTS (
    SELECT *
    FROM Recensione
    WHERE Cliente.Username = Recensione.Autore_Recensione
);

/*ALTRA QUERY: RECENSIONI VISIBILI*/

SELECT ID_Recensione, Cliente.Indirizzo_E_Mail as EMail_Cliente, CIR, BnB.Nome as Struttura, Testo_della_Recensione as Testo
FROM (Recensione 
JOIN Cliente ON (Recensione.Autore_Recensione=Cliente.Username)) 
JOIN BnB ON (BnB.CIR=Recensione.CIR_BnB) 
WHERE Visibilità='True' AND (
	SELECT COUNT(*) FROM Proprietà as P 
	WHERE P.Proprietario IN (
		SELECT Proprietario 
		FROM Proprietà 
		WHERE Proprietà.CIR_BnB =BnB.CIR))>1;	

/*VISTA QUINTUPLA*/

CREATE VIEW Quintupla as
  SELECT R.ID_Recensione,R.Autore_recensione,R.CIR_BnB,V.Tipo_aspect,V.Punteggio_sentiment
  FROM Recensione as R,Proposizione as P,Proposizione_ID as PI,Valutazione as V
  WHERE R.ID_Recensione=P.ID_Recensione and     
  		P.ID_Proposizione = PI.ID_Proposizione and 
		PI.Testo_della_proposizione = V.Testo_della_proposizione;

/*QUERY VISTA QUINTUPLA*/

SELECT DISTINCT Q.ID_Recensione, Q.Autore_recensione, Q.CIR_BnB,R.Testo_della_recensione
FROM Quintupla AS Q,Recensione AS R, Cliente AS C, BnB as B, Indirizzo as CI, Indirizzo as BI
WHERE Q.ID_Recensione = R.ID_Recensione AND (R.Data_pubblicazione between '20190101' and '20230101') AND
	  (Q.Autore_recensione = C.Username AND C.ID_Indirizzo_di_residenza = CI.ID_Indirizzo AND CI.Codice_Postale_Città = '81100') AND
	  (Q.CIR_BnB = B.CIR AND B.ID_Indirizzo = BI.ID_Indirizzo AND BI.Codice_Postale_Città = '84121')

/*VISTA BNB RECENSITI PUNTI DI INTERESSE*/

CREATE VIEW BnB_recensiti_punti_di_interesse AS
SELECT DISTINCT R.id_recensione, B.nome, PDI.categoria
FROM Recensione AS R
JOIN BnB AS B ON (R.CIR_Bnb = B.CIR)
JOIN adiacenza AS AD ON (B.CIR = AD.CIR_Bnb)
JOIN punto_di_interesse AS PDI ON (AD.id_indirizzo_punto_di_interesse = PDI.id_indirizzo);

/*QUERY VISTA BNB RECENSITI PUNTI DI INTERESSE*/

SELECT BR.nome, AVG(V.Punteggio_sentiment *100) AS percentuale_gradimento
FROM BnB_recensiti_punti_di_interesse AS BR
JOIN Proposizione AS PR ON (BR.ID_Recensione = PR.ID_Recensione)
JOIN Proposizione_ID AS PI ON (PR.ID_Proposizione = PI.ID_Proposizione)
JOIN Valutazione AS V ON (PI.Testo_della_proposizione = V.Testo_della_proposizione)
WHERE BR.categoria = 'Musei' OR BR.categoria = 'Chiese'
GROUP BY BR.nome
ORDER BY percentuale_gradimento DESC