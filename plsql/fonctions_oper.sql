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

CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement (
  p_id_equipement IN NUMBER
) RETURN NUMBER IS
  v_etat VARCHAR2(20);
BEGIN
  SELECT etat INTO v_etat FROM EQUIPEMENT WHERE id_equipement = p_id_equipement;
  IF v_etat = 'Disponible' THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF; 
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur verifier_disponibilite_equipement : ' || SQLERRM);
    RETURN 0;
END;
/


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

-- DECLARE
--   v_duree   NUMBER;
--   v_dispo   NUMBER;
--   v_moyenne NUMBER;
-- BEGIN
--   -- Test de la fonction calculer_duree_projet
--   v_duree := calculer_duree_projet(1);
--   DBMS_OUTPUT.PUT_LINE('Durée du projet 1 : ' || v_duree || ' jours');

--   -- Test de la fonction verifier_disponibilite_equipement
--   v_dispo := verifier_disponibilite_equipement(101);
--   IF v_dispo = 1 THEN
--     DBMS_OUTPUT.PUT_LINE('Équipement 101 est disponible.');
--   ELSE
--     DBMS_OUTPUT.PUT_LINE('Équipement 101 n''est pas disponible.');
--   END IF;

--   -- Test de la fonction moyenne_mesures_experience
--   v_moyenne := moyenne_mesures_experience(1001);
--   DBMS_OUTPUT.PUT_LINE('Moyenne des mesures pour l''expérience 1001 : ' || v_moyenne);

-- EXCEPTION
--   WHEN OTHERS THEN
--     DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
-- END;
-- /
 