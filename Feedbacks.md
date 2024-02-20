#Retour app iOS Yves

##Les -:
- Pas de Readme : prez du projet, setup nécessaire etc.
- Deux fichiers manquants a l’ouverture : GoogleService et Constant
- Le projet compile pas (google service plist manquant -> où le DL ?), c’est vraiment dommage car on ne peut pas run le projet, c’est un red flag pour un recruteur
- AppDelegate et SceneDelegate dans le folder Resources, ne sont pas considérés comme tel. Un folder App plutôt ? Assets et plist oui pas de soucis
- Structures par type de fichiers : Model, View, Controller, ViewModels : pas facile de s’y retrouver quand on veut voir le controller et son viewModel. Suggestion : découper par feature et donc avoir la View (View + Controller) avec son VM. Plus facile pour un nouveau de comprendre le projet quand c’est découper par feature. Et souvent on chercher a travailler sur une feature a la fois. Ca évitera des conflits git si par ex 2 devs travaillent dans le meme dossier.
- Tous dans un Main Storyboard. Ca a l’avantage d’avoir une vue macro facile sur le projet par contre ca a plein d’inconvenients comme des conflits git si plusieurs devs sur le projets, un chargement a chaque ouverture, derriere on peut pas review le code car c’est pas du swift mais du XML, etc.
- Les services qui se trouvent dans le dossier Model. Avec la structure actuelle j’aurai mis tous les services dans un dossier Services comme tu as fait pour View, ViewModels etc.
- On se sent vite perdu au niveau de tes models. Ca manque de coherence et de structure. Les types sont pas toujours les bons (String pour un nombre par ex), et on a l'impression que parfois y a de la data pour aider les VM et View a avoir ce qu'ils ont besoin. Cette data est on dirait copier a travers plusieurs model. Ex de la solar category.
- Dans tes assets, si tu n'as pas les differentes taille d'images, met l'asset en single scale dans le panneau de droite (Scale>Single Scale)
- Selon moi CoreData n'etait pas obligatoire les userdefaults auraient suffit mais pour l'entrainement c'est bien quand meme :)

##Les +:
- Pas mal de commits: semble être concis
- La structure restent claire quand meme bien que ce soit par type de fichiers. On n’a pas des fichiers qui se baladent partout
- Utilisation d’un backend
- Utilisation de CoreData
- Utilisation de Services pour accéder a la couche Data (Firebase)
- Custom navigation transition


##Conclusion:

Tu m'as promis du contenu, de la matiere ca oui j'en ai eu hehe :). C'est bien d'avoir pousse un projet perso autant avec beaucoup d'acteur etc.
D'un point de vue recruteur (dev iOS je parle), on voit clairement le niveau Junior. Pour entre autre des raisons comme :
- peu d'utilisation de protocol/ d'abstraction
- utilisation maladroite de techniques comme les generiques
- architecture simple mais ca pourquoi pas ! Le projet ne merite pas specialement + complexe. Le bon point aussi c'est que tu t'es bien tenu a l'archi et la structure du projet

Je n'ai pas non plus tout commente car parfois c'est juste les memes erreurs que dans d'autres fichiers. Et je pense que tu as la assez de commentaires meme si on pourrait encore en mettre un bon paquet, mais no worries c'est normal. Encore une fois c'est des suggestions c'est a toi de voir ;)

Je vais pas te cacher qu'il y a un enormement de travail. Certes je dis pas qu'il faut que tu dev comme un senior mais tu peux t'ameliorer sur la technique. A la fois avoir des meilleurs habitudes sur les methodes de travail (git, PR, small commit, decomposer le code, etc.) sur les conventions et sur l'archi. 
Bravo pour ce projet tout de meme car tu as vu bcp de choses comme le backend avec Firebase et CoreData. Tu as pu mettre les mains dans le pattern MVVM meme s'il est loin d'etre parfait ;)

Je peux t'apporter encore si tu le souhaites, dis toi juste que le travail sera pas facile. A toi de me dire.

## Quelques recommandations:
- Utilise un linter comme SwiftLint, ca va bcp t'aider surtout quand tu demmarre pour ecrire du code proprement, etre encore + rigoureux, apprendre les bonnes pratiques comme eviter les implicit unwrap. C'est selon moi un outil primordiale dans n'importe quel projet.
- MVVM est a revoir :
    - ta view et VC font encore bcp de logique qui devrait etre dans ton VM. Retient que la view est ce qu'il y a de + bete dans une app, elle ne fait qu'afficher ce qu'on lui donne et dit de faire, pas de calcul autre que des calcul de View (positionnement, pixel, frame, animation, etc.). Tout le reste doit etre dans ton VM
    - ta view ne doit pas pouvoir modifier le VM : les properties doivent etre soit `let` soit `private(set)`
    - la view ne doit pas donner d'ordre au VM. Elle ne fait que le notifier d'event utilisateur comme des tap de bouton, ou autre.
- Jete un oeil au pattern Coordinator ou Router pour que tu puisses eviter d'avoir ta logique de navigation dans ta view
- Met ce lien en favoris et potasse le autant que possible. Ca va te donner les convention qu'on a en Swift : https://www.swift.org/documentation/api-design-guidelines/ et celui la https://google.github.io/swift/
- Je pense qu'un projet plus simple cad 2-3 ecrans grand max ou tout le code est clean bien fait on s'eparpille pas serait pas mal a avoir pour presenter en entretien. Moin de code mais du meilleur code :)
