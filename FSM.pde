/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, /* Etat Initial */
  NORMALE,
  ERREUR,

  CREER,
  SUPPRIMER,
  
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION,
  CHANGER_COULEUR_SELECTION,
  
  AFFICHER_FORMES,
  QUITTER, 
}
