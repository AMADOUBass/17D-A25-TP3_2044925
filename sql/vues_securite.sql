CREATE OR REPLACE VIEW V_PROJETS_PUBLICS AS
SELECT id_projet,
       titre,
       domaine_scientifique,
       budget,
       date_debut,
       date_fin,
       id_chercheur_resp
FROM PROJET
WHERE date_fin < SYSDATE;
/
CREATE OR REPLACE VIEW V_RESULTATS_EXPERIENCE AS
SELECT e.id_exp,
       e.titre_exp,
       e.date_realisation,
       e.statut,
       p.titre AS titre_projet,
       p.domaine_scientifique AS domaine_projet,
       c.nom AS nom_chercheur,
       c.prenom AS prenom_chercheur,
       COUNT(ect.id_echantillon) AS nb_echantillons,
       AVG(ect.mesure) AS moyenne_mesure,
       MAX(DBMS_LOB.SUBSTR(e.resultat, 4000, 1)) AS resultat_exp,
       (p.date_fin - p.date_debut) AS duree_projet
FROM EXPERIENCE e
JOIN PROJET p ON e.id_projet = p.id_projet
JOIN CHERCHEUR c ON p.id_chercheur_resp = c.id_chercheur
LEFT JOIN ECHANTILLON ect ON e.id_exp = ect.id_exp
GROUP BY e.id_exp, e.titre_exp, e.date_realisation, e.statut,
         p.titre, p.domaine_scientifique, c.nom, c.prenom,
         p.date_fin, p.date_debut;


-- Droits pour GEST_LAB : toutes les procédures sauf supprimer_projet
GRANT EXECUTE ON ajouter_projet TO GEST_LAB;
GRANT EXECUTE ON planifier_experience TO GEST_LAB;
GRANT EXECUTE ON affecter_equipement TO GEST_LAB;
GRANT EXECUTE ON journaliser_action TO GEST_LAB;

-- Droits pour LECT_LAB : uniquement les vues et fonctions de reporting
GRANT SELECT ON V_PROJETS_PUBLICS TO LECT_LAB;
GRANT SELECT ON V_RESULTATS_EXPERIENCE TO LECT_LAB;
GRANT EXECUTE ON statistiques_equipements TO LECT_LAB;
GRANT EXECUTE ON budget_moyen_par_domaine TO LECT_LAB;

