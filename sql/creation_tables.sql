SET SERVEROUTPUT ON;

-- ========================
-- TABLE CHERCHEUR
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CHERCHEUR CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE CHERCHEUR (
      id_chercheur NUMBER PRIMARY KEY,
      nom VARCHAR2(50) NOT NULL,
      prenom VARCHAR2(50) NOT NULL,
      specialite VARCHAR2(30) NOT NULL CHECK (specialite IN (''Biotech'', ''IA'', ''Physique'', ''Chimie'', ''Mathématiques'', ''Autre'')),
      date_embauche DATE NOT NULL
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur CHERCHEUR : ' || SQLERRM);
END;
/

-- ========================
-- TABLE PROJET
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PROJET CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE PROJET (
      id_projet NUMBER PRIMARY KEY,
      titre VARCHAR2(100) NOT NULL,
      domaine_scientifique VARCHAR2(50) NOT NULL,
      budget NUMBER(10,2) NOT NULL CHECK (budget > 0),
      date_debut DATE NOT NULL,
      date_fin DATE NOT NULL,
      id_chercheur_resp NUMBER NOT NULL,
      CONSTRAINT fk_chercheur_resp FOREIGN KEY (id_chercheur_resp) REFERENCES CHERCHEUR(id_chercheur)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur PROJET : ' || SQLERRM);
END;
/

-- ========================
-- TABLE EQUIPEMENT
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE EQUIPEMENT CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE EQUIPEMENT (
      id_equipement NUMBER PRIMARY KEY,
      nom VARCHAR2(100) NOT NULL,
      categorie VARCHAR2(50) NOT NULL,
      date_acquisition DATE NOT NULL ,
      etat VARCHAR2(20) NOT NULL CHECK (etat IN (''Disponible'', ''En maintenance'', ''Hors service''))
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur EQUIPEMENT : ' || SQLERRM);
END;
/

-- ========================
-- TABLE AFFECTATION_EQUIP
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE AFFECTATION_EQUIP CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE AFFECTATION_EQUIP (
      id_affect NUMBER PRIMARY KEY,
      id_projet NUMBER NOT NULL,
      id_equipement NUMBER NOT NULL,
      date_affectation DATE NOT NULL,
      duree_jours NUMBER NOT NULL CHECK (duree_jours > 0),
      CONSTRAINT fk_affect_projet FOREIGN KEY (id_projet) REFERENCES PROJET(id_projet),
      CONSTRAINT fk_affect_equipement FOREIGN KEY (id_equipement) REFERENCES EQUIPEMENT(id_equipement)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur AFFECTATION_EQUIP : ' || SQLERRM);
END;
/

-- ========================
-- TABLE EXPERIENCE
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE EXPERIENCE CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE EXPERIENCE (
      id_exp NUMBER PRIMARY KEY,
      id_projet NUMBER NOT NULL,
      titre_exp VARCHAR2(100) NOT NULL,
      date_realisation DATE NOT NULL,
      resultat CLOB,
      statut VARCHAR2(20) NOT NULL CHECK (statut IN (''En cours'', ''Terminée'', ''Annulée'')),
      reussite VARCHAR2(3) CHECK (reussite IN (''OUI'', ''NON'')),
      CONSTRAINT fk_exp_projet FOREIGN KEY (id_projet) REFERENCES PROJET(id_projet)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur EXPERIENCE : ' || SQLERRM);
END;
/

-- ========================
-- TABLE ECHANTILLON
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ECHANTILLON CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE ECHANTILLON (
      id_echantillon NUMBER PRIMARY KEY,
      id_exp NUMBER NOT NULL,
      type_echantillon VARCHAR2(50) NOT NULL,
      date_prelevement DATE NOT NULL,
      mesure NUMBER(10,2) NOT NULL CHECK (mesure >= 0),
      CONSTRAINT fk_echantillon_exp FOREIGN KEY (id_exp) REFERENCES EXPERIENCE(id_exp)
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur ECHANTILLON : ' || SQLERRM);
END;
/

-- ========================
-- TABLE LOG_OPERATION
-- ========================
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE LOG_OPERATION CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE LOG_OPERATION (
      id_log NUMBER PRIMARY KEY,
      table_concernee VARCHAR2(50) NOT NULL,
      operation VARCHAR2(10) NOT NULL CHECK (operation IN (''INSERT'', ''UPDATE'', ''DELETE'')),
      utilisateur VARCHAR2(50) NOT NULL,
      date_op DATE DEFAULT SYSDATE,
      description CLOB
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur LOG_OPERATION : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE '
  CREATE TABLE MESURE (
    id_mesure NUMBER PRIMARY KEY,
    id_experience NUMBER NOT NULL,
    valeur NUMBER NOT NULL,
    date_mesure DATE DEFAULT SYSDATE,
    CONSTRAINT fk_mesure_experience FOREIGN KEY (id_experience) REFERENCES EXPERIENCE(id_exp)
  )'
  ;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
