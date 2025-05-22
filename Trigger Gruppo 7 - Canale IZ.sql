/* TRIGGER POPOLAMENTO */

CREATE OR REPLACE FUNCTION verificaCardinalità() returns TRIGGER AS $$
BEGIN
IF (EXISTS (SELECT Username FROM Proprietario 
            WHERE Username NOT IN (SELECT Proprietario FROM Proprietà))) THEN
            RAISE EXCEPTION 'Operazione non possibile';
END IF;
IF (EXISTS (SELECT CIR FROM BnB 
            WHERE CIR NOT IN (SELECT CIR_BnB FROM Proprietà))) THEN
            RAISE EXCEPTION 'Operazione non possibile';
END IF;
return NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER verificaCardinalità
AFTER INSERT ON Proprietario
FOR EACH ROW execute procedure verificaCardinalità();

CREATE TRIGGER verificaCardinalità
AFTER INSERT ON BnB
FOR EACH ROW execute procedure verificaCardinalità();

CREATE TRIGGER verificaCardinalità
AFTER DELETE ON Proprietà
FOR EACH ROW execute procedure verificaCardinalità();

/*TRIGGER REGOLA AZIENDALE */
CREATE OR REPLACE FUNCTION verifica_codice_fiscale() RETURNS trigger AS
$$
BEGIN
	if(EXISTS( SELECT * FROM Proprietario WHERE Username IN 
			  (SELECT Proprietario FROM Proprietà WHERE CIR_BnB = NEW.CIR_BNB) AND 
			  Codice_Fiscale IN ( SELECT Codice_Fiscale FROM Cliente WHERE Username = NEW.Autore_recensione))) THEN
		RAISE EXCEPTION 'Il codice fiscale del cliente è uguale al codice fiscale del proprietario della struttura che si sta recensendo';
	end if;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER condizione_inserimento_recensione
BEFORE INSERT OR UPDATE ON Recensione
FOR EACH ROW
EXECUTE PROCEDURE verifica_codice_fiscale();
