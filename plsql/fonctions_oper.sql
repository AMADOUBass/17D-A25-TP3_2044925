CREATE OR REPLACE FUNCTION calculer_duree_projet (
  p_id_projet IN NUMBER
) RETURN NUMBER IS
  v_debut DATE;
  v_fin DATE;
BEGIN
  SELECT date_debut, date_fin INTO v_debut, v_fin FROM PROJET WHERE id_projet = p_id_projet;
  RETURN v_fin - v_debut;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur calculer_duree_projet : ' || SQLERRM);
    RETURN NULL;
END;
/
-- verifier_disponibilite_equipement(id_equipement) Retourne 1 si l’équipement est 
-- libre, 0 sinon. 
-- Implémente une collection 
-- TABLE OF RECORD.
-- CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement(
--   id_equipement IN NUMBER
-- ) RETURN BOOLEAN IS


CREATE OR REPLACE FUNCTION moyenne_mesures_experience (
  p_id_exp IN NUMBER
) RETURN NUMBER IS
  v_moyenne NUMBER;
BEGIN
  SELECT AVG(mesure) INTO v_moyenne FROM ECHANTILLON WHERE id_exp = p_id_exp;
  RETURN v_moyenne;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur moyenne_mesures_experience : ' || SQLERRM);
    RETURN NULL;
END;
/

