# Projet Base de Données Laboratoire

## 👥 Contributeurs

- Amadou Bassoum — Attestation #123456

---

## 📌 Répartition des tâches : Amadou Bassoum

- **Procédures stockées**  
  (ex. `planifier_experience`, `ajouter_projet`, gestion des transactions avec SAVEPOINT/ROLLBACK)
- **Fonctions**  
  (ex. `budget_moyen_par_domaine`, `statistiques_equipements`, fonctions de reporting)
- **Déclencheurs (triggers)**  
  (ex. `trg_projet_before_insert`, `trg_affectation_after_insert`, `trg_experience_after_insert`)
- **Rapport et documentation**  
  (sections sur sécurité, sauvegardes, journaux de transactions, README.md)

---

## 🚀 Instructions de lancement

1. **Création des tables**  
   Exécuter le script `sql/creation_tables.sql` dans Oracle SQL\*Plus ou SQL Developer.
2. **Création des triggers et procédures**  
   Exécuter `plsql/triggers.sql` puis `plsql/procedures_oper.sql`.
3. **Création des vues et sécurité**  
   Exécuter `sql/vues_securite.sql` pour générer les vues sécurisées et attribuer les privilèges.
4. **Création des utilisateurs et rôles**  
   Exécuter `sql/creation_utilisateurs.sql` pour créer les comptes (`ADMIN_LAB`, `GEST_LAB`, `LECT_LAB`) et leur attribuer les droits.
5. **Tests**  
   ⚠️ Tous les tests sont regroupés dans le fichier `tests/tests_blocs.sql`.  
   Il suffit d’exécuter ce fichier pour valider le bon fonctionnement des procédures, fonctions, triggers et reporting.

---

## 📅 Date de remise

- 12 décembre 2025

---

## 📊 État du projet

- ✅ Tables créées et contraintes définies
- ✅ Triggers implémentés et testés
- ✅ Procédures transactionnelles avec SAVEPOINT/ROLLBACK
- ✅ Vues sécurisées et gestion des rôles (`GEST_LAB`, `LECT_LAB`)
- ✅ Rapport rédigé (sauvegardes, journaux, sécurité)
- ✅ Tests finaux regroupés dans `tests_blocs.sql` et validation complète
