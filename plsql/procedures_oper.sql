-- ========================
-- Séquence pour LOG_OPERATION
-- ========================
CREATE SEQUENCE LOG_OPERATION_SEQ
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
/

-- ========================
-- Procédure AJOUTER_PROJET
-- ========================
CREATE OR REPLACE PROCEDURE ajouter_projet (
  p_id_projet        IN PROJET.id_projet%TYPE,
  p_titre            IN PROJET.titre%TYPE,
  p_domaine          IN PROJET.domaine_scientifique%TYPE,
  p_budget           IN PROJET.budget%TYPE,
  p_date_debut       IN PROJET.date_debut%TYPE,
  p_date_fin         IN PROJET.date_fin%TYPE,
  p_id_chercheur     IN PROJET.id_chercheur_resp%TYPE
) IS
  v_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_exists
  FROM CHERCHEUR
  WHERE id_chercheur = p_id_chercheur;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Chercheur responsable inexistant.');
  END IF;

  INSERT INTO PROJET (id_projet, titre, domaine_scientifique, budget, date_debut, date_fin, id_chercheur_resp)
  VALUES (p_id_projet, p_titre, p_domaine, p_budget, p_date_debut, p_date_fin, p_id_chercheur);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur ajouter_projet : ' || SQLERRM);
END;
/

-- ========================
-- Fonction VERIFIER_DISPONIBILITE_EQUIPEMENT
-- ========================
CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement (
  p_id_equipement IN EQUIPEMENT.id_equipement%TYPE
) RETURN NUMBER IS
  v_etat EQUIPEMENT.etat%TYPE;
BEGIN
  SELECT etat INTO v_etat
  FROM EQUIPEMENT
  WHERE id_equipement = p_id_equipement;

  IF v_etat = 'Disponible' THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/

-- ========================
-- Procédure AFFECTER_EQUIPEMENT
-- ========================
CREATE OR REPLACE PROCEDURE affecter_equipement (
  p_id_affect     IN AFFECTATION_EQUIP.id_affect%TYPE,
  p_id_projet     IN AFFECTATION_EQUIP.id_projet%TYPE,
  p_id_equipement IN AFFECTATION_EQUIP.id_equipement%TYPE,
  p_date_affect   IN AFFECTATION_EQUIP.date_affectation%TYPE,
  p_duree         IN AFFECTATION_EQUIP.duree_jours%TYPE
) IS
  v_dispo NUMBER;
BEGIN
  v_dispo := verifier_disponibilite_equipement(p_id_equipement);
  IF v_dispo = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Équipement non disponible.');
  END IF;

  INSERT INTO AFFECTATION_EQUIP (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
  VALUES (p_id_affect, p_id_projet, p_id_equipement, p_date_affect, p_duree);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur affecter_equipement : ' || SQLERRM);
END;
/

-- ========================
-- Procédure JOURNALISER_ACTION
-- ========================
CREATE OR REPLACE PROCEDURE journaliser_action (
  p_table     IN VARCHAR2,
  p_operation IN VARCHAR2,
  p_user      IN VARCHAR2,
  p_desc      IN CLOB
) IS
BEGIN
  INSERT INTO LOG_OPERATION (id_log, table_concernee, operation, utilisateur, date_op, description)
  VALUES (LOG_OPERATION_SEQ.NEXTVAL, p_table, p_operation, p_user, SYSDATE, p_desc);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur journaliser_action : ' || SQLERRM);
END;
/

-- ========================
-- Procédure PLANIFIER_EXPERIENCE
-- ========================
CREATE OR REPLACE PROCEDURE planifier_experience (
  p_id_exp     IN EXPERIENCE.id_exp%TYPE,
  p_id_projet  IN EXPERIENCE.id_projet%TYPE,
  p_titre      IN EXPERIENCE.titre_exp%TYPE,
  p_date       IN EXPERIENCE.date_realisation%TYPE,
  p_statut     IN EXPERIENCE.statut%TYPE,
  p_id_equip   IN EQUIPEMENT.id_equipement%TYPE,
  p_duree      IN NUMBER
) IS
BEGIN
  INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, resultat, statut)
  VALUES (p_id_exp, p_id_projet, p_titre, p_date, NULL, p_statut);

  affecter_equipement(p_id_exp + 1000, p_id_projet, p_id_equip, p_date, p_duree);

  journaliser_action('EXPERIENCE', 'INSERT', 'admin_rd', 'Expérience planifiée');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur planifier_experience : ' || SQLERRM);
END;
/

-- ========================
-- Procédure SUPPRIMER_PROJET
-- ========================
CREATE OR REPLACE PROCEDURE supprimer_projet (
  p_id_projet IN PROJET.id_projet%TYPE
) IS
BEGIN
  FOR rec IN (SELECT id_exp FROM EXPERIENCE WHERE id_projet = p_id_projet) LOOP
    DELETE FROM ECHANTILLON WHERE id_exp = rec.id_exp;
  END LOOP;

  DELETE FROM EXPERIENCE WHERE id_projet = p_id_projet;
  DELETE FROM AFFECTATION_EQUIP WHERE id_projet = p_id_projet;
  DELETE FROM PROJET WHERE id_projet = p_id_projet;

  journaliser_action('PROJET', 'DELETE', 'admin_rd', 'Suppression complète du projet');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur supprimer_projet : ' || SQLERRM);
END;
/


