-- ========================
-- Séquences nécessaires
-- ========================
CREATE SEQUENCE log_operation_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_experience START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_chercheur START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ========================
-- Vérification avant insertion dans PROJET
-- ========================
CREATE OR REPLACE TRIGGER trg_projet_before_insert
BEFORE INSERT ON projet
FOR EACH ROW
DECLARE
    e_invalid_dates EXCEPTION;
    e_invalid_budget EXCEPTION;
BEGIN
    IF :NEW.date_fin < :NEW.date_debut THEN
        RAISE e_invalid_dates;
    END IF;
    IF :NEW.budget <= 0 THEN
        RAISE e_invalid_budget;
    END IF;
EXCEPTION
    WHEN e_invalid_dates THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erreur: La date de fin doit être postérieure à la date de début.');
    WHEN e_invalid_budget THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur: Le budget doit être un montant positif.');
END trg_projet_before_insert;
/

-- ========================
-- Vérification disponibilité avant affectation
-- ========================
CREATE OR REPLACE TRIGGER trg_affectation_before_insert
BEFORE INSERT ON affectation_equip
FOR EACH ROW
DECLARE
    e_equipement_not_available EXCEPTION;
    v_etat EQUIPEMENT.etat%TYPE;
BEGIN
    SELECT etat INTO v_etat FROM EQUIPEMENT WHERE id_equipement = :NEW.id_equipement;
    IF v_etat <> 'Disponible' THEN
        RAISE e_equipement_not_available;
    END IF;
EXCEPTION
    WHEN e_equipement_not_available THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur: L''équipement n''est pas disponible pour l''affectation.');
END trg_affectation_before_insert;
/

-- ========================
-- Mise à jour état après affectation
-- ========================
CREATE OR REPLACE TRIGGER trg_affectation_after_insert
AFTER INSERT ON affectation_equip
FOR EACH ROW
BEGIN
    UPDATE EQUIPEMENT
    SET etat = 'Hors service'
    WHERE id_equipement = :NEW.id_equipement;
END trg_affectation_after_insert;
/

-- ========================
-- Remise à dispo après suppression d'affectation
-- ========================
CREATE OR REPLACE TRIGGER trg_affectation_after_delete
AFTER DELETE ON affectation_equip
FOR EACH ROW
BEGIN
    UPDATE EQUIPEMENT
    SET etat = 'Disponible'
    WHERE id_equipement = :OLD.id_equipement;
END trg_affectation_after_delete;
/

-- ========================
-- Journalisation insertion EXPERIENCE
-- ========================
CREATE OR REPLACE TRIGGER trg_experience_after_insert
AFTER INSERT ON experience
FOR EACH ROW
DECLARE
    v_username VARCHAR2(30);
BEGIN
    SELECT USER INTO v_username FROM dual;
    INSERT INTO log_operation (id_log, table_concernee, operation, utilisateur, date_op, description)
    VALUES (log_operation_seq.NEXTVAL, 'EXPERIENCE', 'INSERT', v_username, SYSDATE, 'Insertion expérience');
END trg_experience_after_insert;
/

-- ========================
-- Vérification date prélèvement ECHANTILLON
-- ========================
CREATE OR REPLACE TRIGGER trg_echantillon_before_insert
BEFORE INSERT ON echantillon
FOR EACH ROW
DECLARE
    v_date_realisation EXPERIENCE.date_realisation%TYPE;
    e_invalid_prelevement_date EXCEPTION;
BEGIN
    BEGIN
        SELECT date_realisation INTO v_date_realisation
        FROM EXPERIENCE
        WHERE id_exp = :NEW.id_exp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'Erreur: Expérience inexistante.');
    END;

    IF :NEW.date_prelevement < v_date_realisation THEN
        RAISE e_invalid_prelevement_date;
    END IF;
EXCEPTION
    WHEN e_invalid_prelevement_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erreur: La date de prélèvement ne peut pas être antérieure à la date de réalisation de l''expérience.');
END trg_echantillon_before_insert;
/

-- ========================
-- Uniformisation des opérations dans LOG_OPERATION
-- ========================
CREATE OR REPLACE TRIGGER trg_log_before_insert
BEFORE INSERT ON log_operation
FOR EACH ROW
BEGIN
    :NEW.operation := UPPER(:NEW.operation);
END trg_log_before_insert;
/

-- ========================
-- Journalisation mise à jour CHERCHEUR
-- ========================
CREATE OR REPLACE TRIGGER trg_chercheur_after_update
AFTER UPDATE ON chercheur
FOR EACH ROW
DECLARE
    v_username VARCHAR2(30);
BEGIN
    SELECT USER INTO v_username FROM dual;
    INSERT INTO log_operation (id_log, table_concernee, operation, utilisateur, date_op, description)
    VALUES (log_operation_seq.NEXTVAL, 'CHERCHEUR', 'UPDATE', v_username, SYSDATE, 'Mise à jour chercheur');
END trg_chercheur_after_update;
/

-- ========================
-- Vérification dates projet
-- ========================
CREATE OR REPLACE TRIGGER trg_projet_dates
BEFORE INSERT OR UPDATE ON PROJET
FOR EACH ROW
BEGIN
  IF :NEW.date_fin < :NEW.date_debut THEN
    RAISE_APPLICATION_ERROR(-20002, 'La date de fin doit être postérieure à la date de début');
  END IF;
END;
/

-- ========================
-- Vérification date acquisition équipement
-- ========================
CREATE OR REPLACE TRIGGER trg_equipement_date
BEFORE INSERT OR UPDATE ON EQUIPEMENT
FOR EACH ROW
BEGIN
  IF :NEW.date_acquisition > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20003, 'Date d''acquisition invalide');
  END IF;
END;
/