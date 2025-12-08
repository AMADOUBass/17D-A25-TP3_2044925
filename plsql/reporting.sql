CREATE OR REPLACE PROCEDURE rapport_projets_par_chercheur (
  p_id_chercheur IN NUMBER
) IS
  v_total NUMBER := 0;
BEGIN
  FOR rec IN (SELECT titre, budget FROM PROJET WHERE id_chercheur_resp = p_id_chercheur) LOOP
    DBMS_OUTPUT.PUT_LINE('Projet : ' || rec.titre || ' | Budget : ' || rec.budget);
    v_total := v_total + rec.budget;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Budget total : ' || v_total);
END;
/

-- statistiques_equipements() 
-- Fonction 
-- Retourne le 
-- nombre 
-- d’équipements 
-- par état 
-- (disponible, 
-- occupé). 
-- Retourne un tableau de RECORD

-- rapport_activite_projets() 
-- Retourne un tableau de 
-- RECORD. 
-- Procédure Affiche le nombre 
-- d’expériences 
-- réalisées par 
-- projet et leur taux 
-- de réussite. 
-- Appelle 
-- moyenne_mesures_experience. 

-- budget_moyen_par_domaine() 
-- Fonction 
-- Calcule le budget 
-- moyen par 
-- domaine 
-- scientifique. 
-- Utilise une table PL/SQL en 
-- mémoire.