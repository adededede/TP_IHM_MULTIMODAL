import fr.dgac.ivy.*;


class Geste{
  Ivy bus_geste;
  String message_geste;
  String forme;
  String taux_confiance;
  String position;
  String position_objet;
  
  FSM mae; // Finite Sate Machine
  
  Geste(String adresse){
    try{
      // création du bus dédié à la capture de geste
      bus_geste = new Ivy("Geste","Geste Ready", null);
      bus_geste.start(adresse);
      // on récupere tous les messages
      bus_geste.bindMsg("^(.*)", new IvyMessageListener(){
        @Override
        public void receive(IvyClient client, String[] args) {
          String simulation = args[0];
          System.out.println("RECEIVE " + simulation);
          System.out.println(" commande: " + message_geste);
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
  
    // FINALE: ON REGARDE LE TAUX DE CONFIANCE
    taux_confiance = analyse_type(message,"confidence");
    
    // On met à jour la variable message
    // FORMAT: forme' 'couleur' 'position' 'position_objet
    message_geste = forme + " " + position + " " + position_objet;
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
    return bus_geste;
  }
  
  String get_message(){
    return message_geste;
  }
  
  String get_forme(){
    return forme;
  }
  
  String get_confiance(){
    return taux_confiance;
  }
  
  String get_position(){
    return position;
  }
  
  String get_position_objet(){
    return position_objet;
  }
} 
