CREATE OR REPLACE PROCEDURE planifier_experience (
    p_id_exp        IN NUMBER,
    p_id_projet     IN NUMBER,
    p_titre_exp     IN VARCHAR2,
    p_date_real     IN DATE,
    p_statut        IN VARCHAR2,
    p_id_equip      IN NUMBER,
    p_duree_jours   IN NUMBER
) IS
    e_affectation_failed EXCEPTION;
BEGIN
    -- Étape 1 : Création de l'expérience
    INSERT INTO experience (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (p_id_exp, p_id_projet, p_titre_exp, p_date_real, p_statut);

    -- Étape 2 : SAVEPOINT avant l'affectation
    SAVEPOINT avant_affectation;

    BEGIN
        -- Étape 3 : Affectation de l'équipement
        INSERT INTO affectation_equip (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
        VALUES (p_id_exp + 1000, p_id_projet, p_id_equip, SYSDATE, p_duree_jours);

    EXCEPTION
        WHEN OTHERS THEN
            -- Étape 4 : rollback uniquement l'affectation
            ROLLBACK TO avant_affectation;
            RAISE e_affectation_failed;
    END;

    -- Étape 5 : Validation finale
    COMMIT;

EXCEPTION
    WHEN e_affectation_failed THEN
        RAISE_APPLICATION_ERROR(-20010, 'Erreur lors de l''affectation de l''équipement. Expérience créée mais sans équipement.');
    WHEN OTHERS THEN
        -- Étape 6 : rollback complet si autre erreur
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Erreur inattendue lors de la planification de l''expérience.');
END planifier_experience;
/

-- Tests de la procédure planifier_experience
SET SERVEROUTPUT ON;
BEGIN
  planifier_experience(999, 101, 'Expérience Test', SYSDATE, 'En cours', 201, 30);
  DBMS_OUTPUT.PUT_LINE('Expérience planifiée avec succès.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
-- Exemple d'appel de la procédure qui fait échouer l'affectation

SET SERVEROUTPUT ON;
UPDATE EQUIPEMENT
SET etat = 'En maintenance'
WHERE id_equipement = 201;
COMMIT;

BEGIN
  planifier_experience(
    p_id_exp      => 1001,
    p_id_projet   => 101,
    p_titre_exp   => 'Expérience Test Rollback',
    p_date_real   => SYSDATE,
    p_statut      => 'En cours',
    p_id_equip    => 201,   
    p_duree_jours => 30
  );
  DBMS_OUTPUT.PUT_LINE('Expérience planifiée avec succès.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur capturée : ' || SQLERRM);
END;
/

-- 3. Vérifier le résultat
SELECT * FROM EXPERIENCE WHERE id_exp = 1001;
SELECT * FROM AFFECTATION_EQUIP WHERE id_projet = 101 AND id_equipement = 201;