/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */
 
import java.awt.Point;
import java.awt.Color;
import java.util.Random;

ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;
String message_erreur;
int nb_save = 0;
String adresse = "127.255.255.255:2010";
Point position_temp = null;

Ivy bus_geste;
String message_geste;
String taux_confiance_geste;

Ivy bus_parole;
String message_parole;
String action;
String forme;
String couleur;
String pointage_objet;
String position_objet;
String taux_confiance_parole;

void setup() {
  size(800,600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  surface.setLocation(20,20);
  sketch_icon = loadImage("Palette.jpg");
  surface.setIcon(sketch_icon);
  
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;
  try{
      // création du bus dédié à la parole
      bus_parole = new Ivy("Parole","Parole Ready", null);
      bus_parole.start(adresse);
      // on récupere tous les messages
      bus_parole.bindMsg("^sra5 Parsed=(.*)", new IvyMessageListener(){
        @Override
        public void receive(IvyClient client, String[] args) {
          String simulation = args[0];
          println("RECEIVE " + simulation);
          analyse(simulation, "P");
          if(message_parole.equalsIgnoreCase("0")){
              message_erreur = "la demande n'est pas conforme, demande: " + simulation;
          }
          else if(float(taux_confiance_parole)<0.5){
              message_erreur = "le taux de confiance est trop faible, taux de confiance: " + float(taux_confiance_parole);
          }
          else{
              println(" commande: "  + message_parole + " tx_confiance: " + taux_confiance_parole);
              // mise à jour de la FSM en fonction des actions demandé
              realisation();
          }
        }
      });
    }
    catch(IvyException e){
      println("IvyException: PAROLE : " + e);
    }
    try{  
      // création du bus dédié à la capture de geste
      bus_geste = new Ivy("Geste","Geste Ready", null);
      bus_geste.start(adresse);
      // on récupere tous les messages
      bus_geste.bindMsg("^OneDollarIvy (.*)", new IvyMessageListener(){
        @Override
        public void receive(IvyClient client, String[] args) {
          String simulation = args[0];
          println("RECEIVE " + simulation);
          analyse(simulation, "G");
          println(" commande: "  + message_geste + " tx_confiance: " + taux_confiance_geste);
          // mise à jour de la FSM en fonction des actions demandé
          realisation();
        }
      });
    }
    catch(IvyException e){
      println("IvyException: GESTE : " + e);
    }
}

void draw() {
  //background(255);
  // println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      text("s(ave) pour sauvegarder la fenetre courante sous forme d'image", 50,110);
      text("click sur un objet pour changer sa couleur de manière aléatoire", 50,140);
      break;
      
    case CREER: 
      // creation de la forme
      if (forme.equalsIgnoreCase("undefined") && pointage_objet.equalsIgnoreCase("this")){
        //la forme n'a pas été définie vocalement
        break;
      }  
      else if(forme.equalsIgnoreCase("CIRCLE")||forme.equalsIgnoreCase("TRIANGLE")|| forme.equalsIgnoreCase("RECTANGLE")|| forme.equalsIgnoreCase("DIAMOND")){ 
        //on dessine la forme voulu
        if(position_objet.equalsIgnoreCase("UNDEFINED") && !couleur.equalsIgnoreCase("THIS")){
          creer_forme(get_random_position());
          mae = FSM.AFFICHER_FORMES;
        }
        // sinon la position va etre définis par un clic
        
      }
      else{        
        //on ne reconnait pas la forme demandé 
        message_erreur = "la forme demandé n'est pas reconnue";
        mae = FSM.ERREUR;
      }
      break;
    
    case SUPPRIMER:
      // tous se fait en fonction du clic
      
      break;
       
    case QUITTER:
      exit();
    
    case AFFICHER_FORMES:
      affiche();
      mae = FSM.NORMALE;
      break;
      
    case DEPLACER_FORMES_SELECTION: 
      // tous se fait dans la fonction de détection du clic
       
    case DEPLACER_FORMES_DESTINATION:
      // tous se fait dans la fonction de détection du clic 
      
    case CHANGER_COULEUR_SELECTION:
      // tous se fait dans la fonction de détection du clic
      
    case SELECTION_COULEUR:
      // tous se fait dans la fonction de détection du clic
    
    case ERREUR:   
      println(message_erreur);
      break;
      
    case NORMALE:
      // tout va bien!
      indice_forme=-1;
      break;
    default:
      break;
  }  
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void mousePressed() { // sur l'événement clic
  Point p = new Point(mouseX,mouseY);
  println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    
    case INITIAL:
    // si on est à l'affichage du menu on peut alors effectuer un clic
    // ce qui nous mène à l'affichage du tableau blanc
      mae = FSM.AFFICHER_FORMES;
      break;
    
    case CREER:   
      if(couleur.equalsIgnoreCase("THIS") & position_objet.equalsIgnoreCase("THERE")){
        if(position_temp == null){
          position_temp = p;
          println("position furture inconnue, couleur celle là");
          break;
        }
        else{
          color couleur_temp = -1;
          println(position_temp);
          for (int i=0;i<formes.size();i++) { // we're trying every object in the list       
              if ((formes.get(i)).isClicked(p)) {  
                couleur_temp = (formes.get(i)).getColor();         
              }         
          }
          if(couleur_temp != -1){ 
            println("creation forme");
            creer_forme(position_temp);
            formes.get((formes.size())-1).setColor(couleur_temp);
            position_temp = null;
            mae = FSM.AFFICHER_FORMES;
          }
          else{
            for (int i=0;i<formes.size();i++) { // we're trying every object in the list       
              if ((formes.get(i)).isClicked(position_temp)) {  
                couleur_temp = (formes.get(i)).getColor();         
              }         
            }
            if(couleur_temp != -1){ 
              println("creation forme");
              creer_forme(p);
              formes.get((formes.size())-1).setColor(couleur_temp);
              position_temp = null;
              mae = FSM.AFFICHER_FORMES;
            }
            else{
              message_erreur = "Vous n'avez pas sélectionné de couleur à copier";
              mae = FSM.ERREUR;
            }  
          }
        } 
      }   
      else if(position_objet.equalsIgnoreCase("THERE") & !couleur.equalsIgnoreCase("THIS")){
        creer_forme(p);
        mae=FSM.AFFICHER_FORMES;  
      }   
      else if(position_objet.equalsIgnoreCase("UNDEFINED") & couleur.equalsIgnoreCase("THIS")){
        color couleur_temp = -1;
        for (int i=0;i<formes.size();i++) { // we're trying every object in the list       
            if ((formes.get(i)).isClicked(p)) {  
              couleur_temp = (formes.get(i)).getColor();
            }         
        }
        if(couleur_temp != -1){ 
          creer_forme(get_random_position());
          println(formes);
          println("taille de formes= " + formes.size());
          formes.get((formes.size())-1).setColor(couleur_temp);
          mae = FSM.AFFICHER_FORMES;
        }
        else{
          message_erreur = "Vous n'avez pas sélectionné de couleur à copier";
          mae = FSM.ERREUR;
        } 
      }
      break; 
     
   case NORMALE:
   // on se trouve en état normale et si l'on clic sur une forme
    for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
        }         
     }
     if(indice_forme != -1){
       formes.get(indice_forme).setColor(color(get_random_couleur()[0],get_random_couleur()[1],get_random_couleur()[2]));
       mae = FSM.AFFICHER_FORMES;
     }  
     break;
     
   case SUPPRIMER:
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
          if ((formes.get(i)).isClicked(p)) {
            indice_forme = i;
          }         
       }
       if(indice_forme != -1){
         formes.remove(indice_forme);
         mae = FSM.AFFICHER_FORMES;
       }  
       else{
         message_erreur = "vous n'avez pas sélectionné de forme à supprimer";
         mae = FSM.ERREUR;
       }
     break;
      
   case DEPLACER_FORMES_SELECTION:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.DEPLACER_FORMES_DESTINATION;
        }         
     }
     if(indice_forme == -1){
       //aucune forme n'a été sélectionné
       message_erreur = "Vous n'avez pas sélectionné de forme à déplacer";
       mae = FSM.ERREUR;
     }  
     break;
     
   case DEPLACER_FORMES_DESTINATION:
     if (indice_forme !=-1){
       (formes.get(indice_forme)).setLocation(p);
       mae=FSM.AFFICHER_FORMES;
     }  
     else{
       // logiquement on ne devrait jamais se retrouver dans ce cas là
       // vu que l'on fait déjà la vérification dans DEPLACER_FORMES_SELECTION
       message_erreur = "Vous n'avez pas sélectionné de forme à déplacer";
       mae = FSM.ERREUR;
     }  
     break;
     
    case CHANGER_COULEUR_SELECTION:
      int r = 0;
      int g = 0;
      int b = 0;
      boolean cette_couleur = false;
      println("changer_couleur_selection");
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
          if ((formes.get(i)).isClicked(p)) {
            indice_forme = i;
            println("changer_couleur_selection; clic");
            if(maj_couleur().length==1 && maj_couleur()[0]==-1){ 
              println("changer_couleur_selection; cette couleur");     
                //la couleur égale à this color
                //Il faut attendre le clic de sélection de la couleur
                mae = FSM.SELECTION_COULEUR;
                cette_couleur = true;
            }
            else{
               r = maj_couleur()[0];
               g = maj_couleur()[1];
               b = maj_couleur()[2];
            }
          }         
      }
      if(indice_forme != -1 & !cette_couleur){
        formes.get(indice_forme).setColor(color(r,g,b));
        mae = FSM.AFFICHER_FORMES;
      }
      if(indice_forme == -1){
        message_erreur = "Vous n'avez pas sélectionné de forme à changer de couleur";
        mae = FSM.ERREUR;
      }
      break;
      
    case SELECTION_COULEUR:
      color couleur_temp = -1;
      println("selection_couleur"); 
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list       
          if ((formes.get(i)).isClicked(p)) {  
            println("selection_couleur; clic");  
            couleur_temp = (formes.get(i)).getColor();
          }         
      }
      if(indice_forme != -1){
        if(couleur_temp != -1){
          println("selection_couleur; afficher forme");  
          formes.get(indice_forme).setColor(couleur_temp);
          mae = FSM.AFFICHER_FORMES;
        }
        else{
          message_erreur = "Vous n'avez pas sélectionné de couleur à copier";
          mae = FSM.ERREUR;
        }
      }
      else{
        message_erreur = "Vous n'avez pas sélectionné de forme à changer de couleur";
        mae = FSM.ERREUR;
      }
    default:
      break;
  }
}


void keyPressed() {
  Point p = new Point(mouseX,mouseY);
  // on choisie une couleur random
  int r = get_random_couleur()[0];
  int g = get_random_couleur()[1];
  int b = get_random_couleur()[2];
  switch(key) {
    case 'r':
      Forme f= new Rectangle(p,color(r,g,b));
      formes.add(f);
      mae=FSM.AFFICHER_FORMES;
      break;
      
    case 'c':
      Forme f2=new Cercle(p,color(r,g,b));
      formes.add(f2);
      mae=FSM.AFFICHER_FORMES;
      break;
    
    case 't':
      Forme f3=new Triangle(p,color(r,g,b));
      formes.add(f3);
       mae=FSM.AFFICHER_FORMES;
      break;  
      
    case 'l':
      Forme f4=new Losange(p,color(r,g,b));
      formes.add(f4);
      mae=FSM.AFFICHER_FORMES;
      break;    
      
    case 'm' : // move
      mae=FSM.DEPLACER_FORMES_SELECTION;
      break;    
      
    case 's' : // save image
      if(nb_save > 0){
        save("image-" + nb_save + ".tif");
      }
      else{
        save("image.tif");
      }
      nb_save += 1;
      break;
  }
}

void analyse(String message, String type){
  // le message provient d'un bus geste
   if(type.equalsIgnoreCase("G")){
     println(message);
     forme = analyse_type(message, "Template");
     taux_confiance_geste = analyse_type(message,"Confidence");
   }  
   // le message provient d'un bus parole  
   else{
     // PREMIER: ANALYSE DE LA FORME VOULU
    forme = analyse_type(message, "form");
    
    // DEUXIEME: ON MET A JOUR LA POSITION DE LA FORME CHOISI
    // c'est le where dans le ivy bus recu
    pointage_objet = analyse_type(message, "where");
    
    // TROISIEME: ON MET A JOUR LA POSITION FINALE DU DEPLACEMENT
    // c'est le localisation dans le ivy bus recu
    position_objet = analyse_type(message, "localisation");
  
    // QUATRIEME: ON REGARDE LA COULEUR RENSEIGNER
    couleur = analyse_type(message, "color");
    
    // CINQUIEME: ON REGARDE L'ACTION VOULU
    action = analyse_type(message,"action");
  
    // FINALE: ON REGARDE LE TAUX DE CONFIANCE 
    taux_confiance_parole = analyse_type(message,"Confidence");
  }  
  
  
  // on verifie que le message est une demande logique
  // pour l'action créer
  if(action.equalsIgnoreCase("CREATE")){
    //si la forme est soit une forme (cercle, triangle etc) ou alors un this (ca, cette forme...)
    if(pointage_objet.equalsIgnoreCase("THIS") || forme.equalsIgnoreCase("CIRCLE") || forme.equalsIgnoreCase("TRIANGLE") || forme.equalsIgnoreCase("RECTANGLE") || forme.equalsIgnoreCase("DIAMOND") ){
      // On met à jour la variable message
      // FORMAT: action' 'forme' 'couleur' 'position' 'position_objet
      message_parole = action + " " + forme + " " + couleur + " " + pointage_objet + " " + position_objet;
    }
    else{
      // On met à jour la variable message
      message_parole = "0";
    }
  }  
  // pour l'action bouger
  if(action.equalsIgnoreCase("MOVE")){
    //on a seulement besoin du pointage et de la position
    if(pointage_objet.equalsIgnoreCase("THIS") && position_objet.equalsIgnoreCase("THERE")){
      // On met à jour la variable message
      // FORMAT: action' 'forme' 'couleur' 'position' 'position_objet
      message_parole = action + " " + forme + " " + couleur + " " + pointage_objet + " " + position_objet;
    }
    else{
      // On met à jour la variable message
      message_parole = "0";
    }
  }
  // pour l'action supprimer
  if(action.equalsIgnoreCase("DELETE")){
    //on a seulement besoin d'une forme a supprimer
    if(pointage_objet.equalsIgnoreCase("THIS") || forme.equalsIgnoreCase("CIRCLE") || forme.equalsIgnoreCase("TRIANGLE") || forme.equalsIgnoreCase("RECTANGLE") || forme.equalsIgnoreCase("DIAMOND") ){
      // On met à jour la variable message
      // FORMAT: action' 'forme' 'couleur' 'position' 'position_objet
      message_parole = action + " " + forme + " " + couleur + " " + pointage_objet + " " + position_objet;
    }
    else{
      // On met à jour la variable message
      message_parole = "0";
    }
  }
  // pour l'action changer de couleur
  if(action.equalsIgnoreCase("CHANGE_COLOR")){
    //on a seulement besoin d'une forme et de sa nouvelle couleur
    if(pointage_objet.equalsIgnoreCase("THIS")){
      // On met à jour la variable message
      // FORMAT: action' 'forme' 'couleur' 'position' 'position_objet
      message_parole = action + " " + forme + " " + couleur + " " + pointage_objet + " " + position_objet;
    }
    else{
      // On met à jour la variable message
      message_parole = "0";
    }
  }
  // pour l'action quitter
  if(action.equalsIgnoreCase("QUIT")){
    message_parole = action + " " + forme + " " + couleur + " " + pointage_objet + " " + position_objet;
  }
  
  
}

String analyse_type(String message, String type) {
  String[] champs = message.split(" ");
  for(int i=0; i<champs.length; i++){
    if(champs[i].contains(type)){
      String[] valeur = champs[i].split("=");
      return valeur[1];
    }
  }
  // le message n'est pas une commande
  return "-";
}

void realisation(){
  // analyse de l'action a effectuer
  if(action.equalsIgnoreCase("CREATE")){
    // on veut créer un objet=>mise à jour de la FSM
    mae = FSM.CREER;
  } 
  else if(action.equalsIgnoreCase("QUIT")){
    // on veut quitter => mise à jour de la FSM
    mae = FSM.QUITTER;
  }  
  else if(action.equalsIgnoreCase("MOVE")){
    // on veut bouger un objet => mise à jour de la FSM
    mae = FSM.DEPLACER_FORMES_SELECTION;
  } 
  else if(action.equalsIgnoreCase("DELETE")){
    // on veut supprimer un objet => mise à jour de la FSM
    mae = FSM.SUPPRIMER;
  } 
  else if(action.equalsIgnoreCase("CHANGE_COLOR")){
    // on veut changer la couleur d'un objet => mise à jour de la FSM
    mae = FSM.CHANGER_COULEUR_SELECTION;
  } 
  else{
    // on ne reconnait pas l'action voulu => mise à jour de la FSM
    message_erreur = "l'action enoncé n'est pas reconnue: " + action;
    mae = FSM.ERREUR;
  }
}

void creer_forme(Point p){
  Forme f;
  int r;
  int g;
  int b;
  if(maj_couleur().length==0){
      // on choisie une couleur random
     r = get_random_couleur()[0];
     g = get_random_couleur()[1];
     b = get_random_couleur()[2];
  }
  else if(maj_couleur().length==1){
     r = 0;
     g = 0;
     b = 0;
  }
  else{
     r = maj_couleur()[0];
     g = maj_couleur()[1];
     b = maj_couleur()[2];
  }
  //on regarde quelle est la forme a dessiner
  if(forme.equalsIgnoreCase("TRIANGLE")){
      f = new Triangle(p, color(r,g,b));
      indice_forme = formes.size();
      formes.add(f);
  }
  else if(forme.equalsIgnoreCase("RECTANGLE")){
      f = new Rectangle(p,color(r,g,b));
      indice_forme = formes.size();
      formes.add(f);
  }
  else if(forme.equalsIgnoreCase("DIAMOND")){
      f = new Losange(p,color(r,g,b));
      indice_forme = formes.size();
      formes.add(f);
  }
  else if(forme.equalsIgnoreCase("CIRCLE")){
      f = new Cercle(p,color(r,g,b));
      indice_forme = formes.size();
      formes.add(f);
  }
  else{
      // on ne reconnait pas la forme
      indice_forme = -1;
      message_erreur = "la forme voulu n'est pas reconnue";
      mae = FSM.ERREUR;
  }
}

int[] maj_couleur(){
  if(couleur.equalsIgnoreCase("THIS")){
    int[] zero = new int[1];
    zero[0] = -1;
    return zero;
  }
  if(couleur.equalsIgnoreCase("UNDEFINED")){
    return get_random_couleur();
  }
  else if(couleur.equalsIgnoreCase("ORANGE")){
    int[] liste_couleur = {255, 153, 51};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("RED")){
    int[] liste_couleur = {255, 51, 51};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("YELLOW")){
    int[] liste_couleur = {255, 255, 51};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("GREEN")){
    int[] liste_couleur = {153, 255, 51};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("BLUE")){
    int[] liste_couleur = {51, 153, 255};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("PINK")){
    int[] liste_couleur = {255, 102, 255};
    return liste_couleur;
  }
  else if(couleur.equalsIgnoreCase("BLACK")){
    int[] liste_couleur = {0, 0, 0};
    return liste_couleur;
  }
  else{
      message_erreur = "la couleur voulu n'est pas reconnue";
      mae = FSM.ERREUR;
      return new int[0];
  }
}

int[] get_random_couleur(){
    // on choisie une couleur random
    Random random = new Random();
    // entre 0 et 255
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);
    int[] liste_couleur = {red, green, blue};
    return liste_couleur;
}

Point get_random_position(){
    // on choisi une position random
    Random random = new Random();
    // entre 0 et 255
    int x = random.nextInt(800);
    int y = random.nextInt(600);
    return new Point(x,y);
}
