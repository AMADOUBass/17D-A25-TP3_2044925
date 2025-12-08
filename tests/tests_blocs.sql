BEGIN
  ajouter_projet(999, 'TestProjet', 'IA', 100000, SYSDATE, SYSDATE + 365, 1);
  DBMS_OUTPUT.PUT_LINE('ajouter_projet exécutée avec succès.');
  DELETE FROM PROJET WHERE id_projet = 999;
  COMMIT;
END;
/

BEGIN
  journaliser_action('TEST_TABLE', 'INSERT', 'admin_rd', 'Test log');
  DBMS_OUTPUT.PUT_LINE('journaliser_action exécutée.');
  DELETE FROM LOG_OPERATION WHERE table_concernee = 'TEST_TABLE';
  COMMIT;
END;
/

DECLARE
  v_result NUMBER;
BEGIN
  v_result := verifier_disponibilite_equipement(201);
  DBMS_OUTPUT.PUT_LINE('Disponibilité équipement 201 : ' || v_result);
END;
/

BEGIN
  affecter_equipement(999, 101, 201, SYSDATE, 30);
  DBMS_OUTPUT.PUT_LINE('affecter_equipement exécutée.');
  DELETE FROM AFFECTATION_EQUIP WHERE id_affect = 999;
  COMMIT;
END;
/

BEGIN
  planifier_experience(999, 101, 'Test Expérience', SYSDATE, 'En cours', 201, 45);
  DBMS_OUTPUT.PUT_LINE('planifier_experience exécutée.');
  DELETE FROM EXPERIENCE WHERE id_exp = 999;
  DELETE FROM AFFECTATION_EQUIP WHERE id_affect = 1999;
  COMMIT;
END;
/

BEGIN
  INSERT INTO PROJET VALUES (998, 'Projet Temp', 'Physique', 50000, SYSDATE, SYSDATE + 100, 1);
  supprimer_projet(998);
  DBMS_OUTPUT.PUT_LINE('supprimer_projet exécutée.');
END;
/

DECLARE
  v_duree NUMBER;
BEGIN
  v_duree := calculer_duree_projet(101);
  DBMS_OUTPUT.PUT_LINE('Durée projet 101 : ' || v_duree || ' jours');
END;
/

DECLARE
  v_moy NUMBER;
BEGIN
  v_moy := moyenne_mesures_experience(401);
  DBMS_OUTPUT.PUT_LINE('Moyenne mesures expérience 401 : ' || v_moy);
END;
/