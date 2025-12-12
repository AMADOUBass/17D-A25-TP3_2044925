-- ========================
-- Procédure : rapport_projets_par_chercheur
-- ========================
CREATE OR REPLACE PROCEDURE rapport_projets_par_chercheur (
  p_id_chercheur IN NUMBER
) IS
  CURSOR c_projets IS
    SELECT p.titre, p.budget
    FROM projet p
    WHERE p.id_chercheur_resp = p_id_chercheur;

  v_budget_total NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Projets du chercheur ID: ' || p_id_chercheur);
  DBMS_OUTPUT.PUT_LINE('-----------------------------------');
  FOR r_projet IN c_projets LOOP
    DBMS_OUTPUT.PUT_LINE('Projet: ' || r_projet.titre || ' | Budget: ' || r_projet.budget);
    v_budget_total := v_budget_total + r_projet.budget;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('-----------------------------------');
  DBMS_OUTPUT.PUT_LINE('Budget Total: ' || v_budget_total);
END rapport_projets_par_chercheur;
/
------------------------------------------------------------

-- ========================
-- Types pour statistiques équipements
-- ========================
CREATE OR REPLACE TYPE equipement_stat_record AS OBJECT (
  etat VARCHAR2(20),
  nombre NUMBER
);
/

CREATE OR REPLACE TYPE equipement_stat_table AS TABLE OF equipement_stat_record;
/

-- ========================
-- Fonction : statistiques_equipements
-- ========================
CREATE OR REPLACE FUNCTION statistiques_equipements
RETURN equipement_stat_table IS
  v_stats equipement_stat_table := equipement_stat_table();
BEGIN
  FOR r IN (SELECT etat, COUNT(*) AS nombre
            FROM equipement
            GROUP BY etat) LOOP
    v_stats.EXTEND;
    v_stats(v_stats.COUNT) := equipement_stat_record(r.etat, r.nombre);
  END LOOP;
  RETURN v_stats;
END statistiques_equipements;
/
------------------------------------------------------------

-- ========================
-- Procédure : rapport_activite_projets
-- ========================
CREATE OR REPLACE PROCEDURE rapport_activite_projets IS
BEGIN
  FOR r_projet IN (
    SELECT p.id_projet, p.titre
    FROM projet p
  ) LOOP
    DECLARE
      v_nombre_experiences NUMBER;
      v_taux_reussite NUMBER;
    BEGIN
      SELECT COUNT(*),
             (SUM(CASE WHEN e.reussite = 'OUI' THEN 1 ELSE 0 END) / COUNT(*)) * 100
      INTO v_nombre_experiences, v_taux_reussite
      FROM experience e
      WHERE e.id_projet = r_projet.id_projet;

      DBMS_OUTPUT.PUT_LINE(
        'Projet: ' || r_projet.titre ||
        ' | Nombre d''expériences: ' || v_nombre_experiences ||
        ' | Taux de réussite: ' || NVL(v_taux_reussite,0) || '%'
      );

      FOR r_exp IN (
        SELECT e.id_exp, e.titre_exp
        FROM experience e
        WHERE e.id_projet = r_projet.id_projet
      ) LOOP
        DECLARE
          v_moyenne NUMBER;
        BEGIN
          v_moyenne := moyenne_mesures_experience(r_exp.id_exp);
          DBMS_OUTPUT.PUT_LINE(
            '   Expérience: ' || r_exp.titre_exp ||
            ' | Moyenne des mesures: ' || NVL(v_moyenne,0)
          );
        END;
      END LOOP;
    END;
  END LOOP;
END rapport_activite_projets;
/
------------------------------------------------------------

-- ========================
-- Types pour budget moyen par domaine
-- ========================
CREATE OR REPLACE TYPE budget_moyen_par_domaine_record AS OBJECT (
  domaine_scientifique VARCHAR2(100),
  budget_moyen NUMBER
);
/

CREATE OR REPLACE TYPE budget_moyen_par_domaine_table AS TABLE OF budget_moyen_par_domaine_record;
/

-- ========================
-- Fonction : budget_moyen_par_domaine
-- ========================
CREATE OR REPLACE FUNCTION budget_moyen_par_domaine
RETURN budget_moyen_par_domaine_table IS
  v_resultat budget_moyen_par_domaine_table := budget_moyen_par_domaine_table();
BEGIN
  FOR r IN (SELECT p.domaine_scientifique, AVG(p.budget) AS budget_moyen
            FROM projet p
            GROUP BY p.domaine_scientifique) LOOP
    v_resultat.EXTEND;
    v_resultat(v_resultat.COUNT) := budget_moyen_par_domaine_record(r.domaine_scientifique, r.budget_moyen);
  END LOOP;
  RETURN v_resultat;
END budget_moyen_par_domaine;
/


