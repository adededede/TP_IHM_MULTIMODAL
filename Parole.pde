import fr.dgac.ivy.*;

class Parole{
  Ivy bus_parole;
  String message_parole;
  String action;
  String forme;
  String taux_confiance;
  String couleur;
  String position;
  String position_objet;
  
  FSM mae; // Finite Sate Machine
  
  Parole(String adresse){
    try{
      // création du bus dédié à la parole
      bus_parole = new Ivy("Parole","Parole Ready", null);
      bus_parole.start(adresse);
      // on récupere tous les messages
      bus_parole.bindMsg("^(.*)", new IvyMessageListener(){
        @Override
        public void receive(IvyClient client, String[] args) {
          String simulation = args[0];
          System.out.println("RECEIVE " + simulation);
          System.out.println(" commande: "  + message_parole);
          mae = FSM.NORMALE;
        }
      });
    }
    catch(IvyException e){
      e.printStackTrace();
    }
  }
  
  
  void analyse(String message){
    // PREMIER: ANALYSE DE LA FORME VOULU
    forme = analyse_type(message, "form");
    
    // DEUXIEME: ON MET A JOUR LA POSITION DE LA FORME CHOISI
    // c'est le where dans le ivy bus recu
    position_objet = analyse_type(message, "where");
    
    // TROISIEME: ON MET A JOUR LA POSITION FINALE DU DEPLACEMENT
    // c'est le localisation dans le ivy bus recu
    position = analyse_type(message, "localisation");
  
    // QUATRIEME: ON REGARDE LA COULEUR RENSEIGNER
    couleur = analyse_type(message, "color");
    
    // CINQUIEME: ON REGARDE L'ACTION VOULU
    action = analyse_type(message,"action");
  
    // FINALE: ON REGARDE LE TAUX DE CONFIANCE
    taux_confiance = analyse_type(message,"Confidence");
    
    // On met à jour la variable message
    // FORMAT: action' 'forme' 'couleur' 'position' 'position_objet
    message_parole = action + " " + forme + " " + couleur + " " + position + " " + position_objet;
  }
  
   String analyse_type(String message, String type) {
      int position_type = message.indexOf(type);
      // Si le message contient action alors c'est une commande de l'utilisateur
      if(position_type != -1){
        String message_type = (message.substring(position_type, message.length()));
        int position_espace = message_type.indexOf(" ");
        int difference_taille = message.length() - message_type.length();
        int position_fin_type = position_espace + difference_taille;
        // On récupère l'action donc après entre le action= et l'espace(d'out le +7 au début)
        String action = message.substring(position_type + type.length() + 1, position_fin_type);
        System.out.println("type: " + type + " : " + action);
        return action;
      }
      else{
        // le message n'est pas une commande
        return "-";
      }  
  }
  
  Ivy get_bus(){
    return bus_parole;
  }
  
  String get_action(){
    return action;
  }
  
  String get_message(){
    return message_parole;
  }
  
  String get_forme(){
    return forme;
  }
  
  String get_confiance(){
    return taux_confiance;
  }
  
  String get_couleur(){
    return couleur;
  }
  
  String get_position(){
    return position;
  }
  
  String get_position_objet(){
    return position_objet;
  }
} 
