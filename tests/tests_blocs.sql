SET SERVEROUTPUT ON;

-- ==========================================================
-- == Tests des procédures stockées
-- ==========================================================

PROMPT === Test ajout projet (succès et échec) ===
BEGIN
  -- Cas succès
  ajouter_projet(999, 'TestProjetOK', 'IA', 100000, SYSDATE, SYSDATE + 365, 1);
  DBMS_OUTPUT.PUT_LINE('>>> ajouter_projet exécutée avec succès.');
  DELETE FROM PROJET WHERE id_projet = 999;
  COMMIT;

  -- Cas échec (doublon)
  ajouter_projet(101, 'TestProjetKO', 'IA', 100000, SYSDATE, SYSDATE + 365, 1);
  DBMS_OUTPUT.PUT_LINE('>>> ajouter_projet exécutée (mais devrait échouer).');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('>>> Erreur attendue (ajout projet) : ' || SQLERRM);
END;
/

PROMPT === Test journalisation (succès) ===
BEGIN
  journaliser_action('TEST_TABLE', 'INSERT', 'admin_rd', 'Test log');
  DBMS_OUTPUT.PUT_LINE('>>> journaliser_action exécutée avec succès.');
  DELETE FROM LOG_OPERATION WHERE table_concernee = 'TEST_TABLE';
  COMMIT;
END;
/

PROMPT === Test disponibilité équipement (succès et échec) ===
DECLARE
  v_result NUMBER;
BEGIN
  -- Cas succès
  v_result := verifier_disponibilite_equipement(202);
  DBMS_OUTPUT.PUT_LINE('>>> Disponibilité équipement 202 (succès) : ' || v_result);

  -- Cas échec
  v_result := verifier_disponibilite_equipement(204);
  DBMS_OUTPUT.PUT_LINE('>>> Disponibilité équipement 204 (échec attendu) : ' || v_result);
END;
/

PROMPT === Test affectation équipement (succès et échec) ===
BEGIN
  -- Cas succès
  affecter_equipement(999, 101, 202, SYSDATE, 30);
  DBMS_OUTPUT.PUT_LINE('>>> affecter_equipement exécutée avec succès.');
  DELETE FROM AFFECTATION_EQUIP WHERE id_affect = 999;
  COMMIT;

  -- Cas échec
  affecter_equipement(1000, 101, 204, SYSDATE, 30);
  DBMS_OUTPUT.PUT_LINE('>>> affecter_equipement exécutée (mais devrait échouer).');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('>>> Erreur attendue (affectation équipement) : ' || SQLERRM);
END;
/

PROMPT === Test planification expérience (succès et échec) ===
BEGIN
  -- Cas succès
  planifier_experience(999, 101, 'Expérience OK', SYSDATE, 'En cours', 202, 45);
  DBMS_OUTPUT.PUT_LINE('>>> planifier_experience exécutée avec succès.');
  DELETE FROM EXPERIENCE WHERE id_exp = 999;
  DELETE FROM AFFECTATION_EQUIP WHERE id_affect = 1999;
  COMMIT;

  -- Cas échec
  planifier_experience(1001, 101, 'Expérience KO', SYSDATE, 'En cours', 204, 45);
  DBMS_OUTPUT.PUT_LINE('>>> planifier_experience exécutée (mais devrait échouer).');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('>>> Erreur attendue (planification expérience) : ' || SQLERRM);
END;
/

PROMPT === Test suppression projet (succès et échec) ===
BEGIN
  -- Cas succès
  INSERT INTO PROJET VALUES (9998, 'Projet Temp OK', 'Physique', 50000, SYSDATE, SYSDATE + 100, 1);
  supprimer_projet(9998);
  DBMS_OUTPUT.PUT_LINE('>>> supprimer_projet exécutée avec succès.');

  -- Cas échec
  supprimer_projet(123456);
  DBMS_OUTPUT.PUT_LINE('>>> supprimer_projet exécutée (mais devrait échouer).');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('>>> Erreur attendue (suppression projet) : ' || SQLERRM);
END;
/

-- ==========================================================
-- == Tests des fonctions
-- ==========================================================

PROMPT === Test calcul durée projet ===
DECLARE
  v_duree NUMBER;
BEGIN
  v_duree := calculer_duree_projet(101);
  DBMS_OUTPUT.PUT_LINE('>>> Durée projet 101 : ' || v_duree || ' jours');
END;
/

PROMPT === Test moyenne mesures expérience ===
DECLARE
  v_moy NUMBER;
BEGIN
  v_moy := moyenne_mesures_experience(401);
  DBMS_OUTPUT.PUT_LINE('>>> Moyenne mesures expérience 401 : ' || v_moy);
END;
/

-- ==========================================================
-- == Tests des rapports et vues
-- ==========================================================

PROMPT === Rapport projets par chercheur ===
BEGIN
  rapport_projets_par_chercheur(1);
END;
/

PROMPT === Statistiques équipements ===
SELECT * FROM TABLE(statistiques_equipements);

PROMPT === Rapport activité projets ===
BEGIN
  rapport_activite_projets;
END;
/

PROMPT === Budget moyen par domaine ===
SELECT * FROM TABLE(budget_moyen_par_domaine);

PROMPT === Vérification des vues sécurisées ===
SELECT * FROM V_PROJETS_PUBLICS;
SELECT * FROM V_RESULTATS_EXPERIENCE;

-- ==========================================================
-- == Bloc final de validation
-- ==========================================================

PROMPT === Validation des données après tests ===
SELECT * FROM CHERCHEUR;
SELECT * FROM PROJET;
SELECT * FROM EXPERIENCE;
SELECT * FROM EQUIPEMENT;
SELECT * FROM AFFECTATION_EQUIP;
SELECT * FROM ECHANTILLON;
SELECT * FROM LOG_OPERATION;
