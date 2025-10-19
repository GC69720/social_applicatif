#  Organisation du travail – Board & Milestones

Projet : **Réseau Social – Développement (Prod & R&D)**  
Version : MVP v0.1  
Board GitHub : [MVP Board](https://github.com/users/GC69720/projects/3)

---

##  Objectifs

Ce document formalise la manière dont les **User Stories (US)**, **issues** et **milestones** sont gérés dans GitHub pour le projet.  
Il définit la structure de suivi des tâches, du backlog à la livraison.

---

##  Structure générale
| Élément | Description | Exemple |
|----------|--------------|----------|
| **Milestone** | Regroupe les issues d’un même objectif produit | `MVP v0.1` |
| **Labels** | Catégorisation fonctionnelle et technique | `user-story`, `MVP`, `frontend`, `backend` |
| **Project Board** | Vue Kanban globale du MVP | `MVP Board` |
| **Status (colonne)** | État d’avancement d’une tâche | `Todo → In Progress → In Review → Done` |

---

##  Milestone : MVP v0.1

Toutes les **US** prioritaires sont associées à ce milestone.  
Chaque nouvelle issue (bug, story ou amélioration) doit être associée :
- soit au milestone courant (ex. `MVP v0.1`),
- soit à un futur jalon (`v0.2`, `v1.0`, etc.).

```bash
gh issue edit <numéro> --repo GC69720/social_applicatif --milestone "MVP v0.1"
