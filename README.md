# TP_IHM_MULTIMODAL
Projet IHM multimodal, positionnement de forme en fonction de commandes vocales et/ou gestuelles

## Lancement
Pour lancer ce projet il vous faudra:
  1. le télécharger
  2. lancer le fichier Palette.pde
  3. lancer le fichier OneDollarIvy.pde
  4. lancer la commande suivante *depuis le dossier parole* (cela permet de lancer la capture de dialogue)
```powershell
sra5 -b 127.255.255.255:2010 -g grammaire_parole.grxml -p on
```
## Contexte
Ici, nous réalisons un projet dans le cadre du cours d'IHM Multimodal(M1, Upssitech SRI). Vous pourrez retrouver le sujet en suivant [ce lien](https://github.com/truillet/upssitech/blob/master/SRI/3A/IHM/TP/T3-5_multimodal_interaction.pdf).

Concernant la gestion de dialogue nous utilisons le module sra5 et pour la capture des gestes nous utilisons l'application du OneDollarIvy [suivante](https://github.com/truillet/OneDollarIvy).

