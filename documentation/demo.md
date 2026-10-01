# Déroulé de démonstration

À suivre pendant la soutenance. L'ordre reprend celui de la grille d'évaluation.

**Contrat de référence** : `0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72` (Sepolia)

## Toutes les commandes

Ce sont les seules de la soutenance — tout le reste se fait dans le navigateur, Remix et
MetaMask.

Lancer le site de mint, depuis la racine du dépôt :

```
cd mint
python3 -m http.server 8000
```

Puis ouvrir **http://localhost:8000** dans le navigateur. `Ctrl+C` dans le terminal pour
arrêter le serveur à la fin.

Si le port 8000 est déjà pris, en changer : `python3 -m http.server 8080`, et ouvrir
http://localhost:8080.

## Préparation, avant que le correcteur n'arrive

- MetaMask sur **Sepolia**, compte `0x93Bf...33f9` (le propriétaire), solde non nul
- un second compte disponible — `0xDadC...1101` — pour la démonstration de privilèges,
  **autorisé pour Remix dans les permissions du site** (changer de compte dans MetaMask ne
  suffit pas)
- Remix ouvert, `Essence42.sol` chargé et **compilé**
- **Remix connecté en WalletConnect**, QR code scanné avec MetaMask sur mon téléphone.
  Sur la session du correcteur il n'y a pas mon extension, donc pas d'*Injected Provider* :
  WalletConnect est le seul chemin pour signer. Vérifier que MetaMask mobile est bien sur
  Sepolia, avec une URL RPC qui fonctionne.
- le contrat attaché via *At Address* avec l'adresse de référence
- les liens Blockscout ouverts dans des onglets
- **le site de mint lancé** (voir les commandes ci-dessus) et ouvert sur
  http://localhost:8000. Ne **jamais** ouvrir la page par double-clic : en `file://` elle
  n'a pas d'origine valide, MetaMask refuse de s'y connecter et son interface peut planter.
- MetaMask connecté au site, et un premier mint fait à blanc pour vérifier que la
  confirmation s'ouvre bien

## 1. Montrer le NFT — critère bloquant

https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/0

L'image s'affiche, le 42 est lisible.

Montrer ensuite les exemplaires `1` et `2` : même œuvre, trois teintes nettement
différentes.

> Si le correcteur demande à voir dans un wallet : onglet NFT de l'extension MetaMask.
> Ne **pas** proposer Etherscan — il n'affiche pas l'image. Si la question vient : les
> métadonnées sont au format ERC721 canonique, Blockscout et MetaMask lisent exactement la
> même chaîne ; Etherscan est bâti pour télécharger une image à une URL et traite mal les
> data URI.

## 2. Montrer les métadonnées — critère bloquant

Dans Remix : `tokenURI(0)`.

Copier la chaîne renvoyée (sans le préfixe `0: string:`) et la coller dans la barre
d'adresse d'un navigateur. Le JSON apparaît :

- `"name": "42 Essence #0"` → contient bien 42, et un titre
- `"attributes"` → `artist` vaut `hvernhes`, le login 42

Coller ensuite la valeur du champ `image` dans la barre d'adresse : l'œuvre s'affiche.
C'est la démonstration que **rien n'est stocké ailleurs** — tout sort du contrat.

## 3. Montrer la propriété — critère bloquant

Dans Remix : `ownerOf(0)` → renvoie `0x93Bf190F82D00cbC103f32FaCc32f15a63D233f9`.

Comparer avec le compte actif dans MetaMask : c'est la même adresse.

Puis `ownerOf(3)` → `0xDadC...1101`, et `ownerOf(7)` → `0x87c1...0273` : **trois
propriétaires différents** sur la même collection. C'est exactement ce que le registre
ERC721 permet et que l'ERC20 ne permettait pas — là-bas, on ne comptait que des soldes.

Enfin `ownerOf(9)` → **erreur**. L'exemplaire n'a jamais été minté, le contrat refuse de
répondre.

## 4. Le README

Ouvrir [`README.md`](../README.md). Les points que la fiche vérifie explicitement :

- **le choix de la plateforme** — Sepolia, et pourquoi un testnet est obligatoire
- **le choix du langage** — Solidity, imposé de fait par Ethereum
- la description du dépôt, en fin de fichier

Le passage à défendre si la discussion s'engage : la section sur le **stockage on-chain**,
et pourquoi il satisfait « distributed registry technology » mieux qu'IPFS.

## 5. La documentation

Ouvrir [`usage.md`](usage.md) : la liste des fonctions, comment lire les métadonnées,
comment afficher le NFT, comment fonctionne la variation des teintes.

La fiche demande au correcteur de **retrouver dans le code les fonctions citées par la
documentation** — elles y sont toutes.

## 6. Code review

Ouvrir [`code/Essence42.sol`](../code/Essence42.sol). Le parcourir dans cet ordre :

1. **les imports** — ERC721 et Ownable viennent d'OpenZeppelin, pas réécrits : réimplémenter
   un standard revient à réintroduire des failles déjà éliminées par des années d'audit
2. **`MAX_SUPPLY`** — une `constant`, donc inscrite dans le bytecode, sans emplacement de
   stockage, non modifiable même par le propriétaire. La rareté est vérifiable, pas promise
3. **`mint`** — `onlyOwner`, plus la vérification du plafond avec une erreur personnalisée
   (moins coûteuse en gas qu'un `require` avec message, et le nom remonte tel quel)
4. **`hueOf`** — 13 est premier avec 42, donc la multiplication modulo 42 est une bijection :
   les 42 exemplaires occupent les 42 teintes, une chacune, mais les consécutifs sont
   éloignés. Le décalage de 200 place le token 0 sur le bleu d'origine
5. **`_buildSVG`** — la géométrie est figée, seule la teinte est injectée. En HSL, seul le
   `H` change : le rapport clair/sombre entre facettes est préservé à toutes les teintes,
   donc rien ne peut jurer
6. **`tokenURI`** — le double encodage : le SVG est encodé pour tenir dans le champ `image`,
   puis le JSON entier est encodé à son tour

## 7. Déploiement — le correcteur doit le faire avec toi

Ouvrir [`deployment/DEPLOYMENT.md`](../deployment/DEPLOYMENT.md) : la procédure, les
réglages de compilation, l'ABI.

Souligner qu'**il n'y a aucune clé ni mot de passe dans le dépôt** — c'est un point de
flag sur la fiche. Avec Remix, la clé privée ne quitte jamais MetaMask.

**Déploiement en direct** : *Deploy & Run* → environnement **WalletConnect** (déjà connecté,
voir la préparation) → contrat `Essence42` → *Deploy*. Le constructeur ne prend aucun
argument, il n'y a rien à saisir.

> La nouvelle adresse est différente de celle du dépôt : c'est normal, le code déployé est
> immuable et chaque déploiement crée un contrat distinct. Enchaîner sur le mint ci-dessous,
> puis revenir au contrat de référence pour tout ce qui demande plusieurs exemplaires.

## 8. Mint — le correcteur doit le faire avec toi

Ouvrir [`mint/MINT.md`](../mint/MINT.md).

`mint` avec l'adresse du correcteur, ou la tienne. Puis `ownerOf(0)` pour confirmer, et le
lien Blockscout de l'exemplaire fraîchement créé.

**Puis la démonstration de privilèges** — c'est le point « ownership and privileges » de la
fiche :

1. basculer MetaMask sur `0xDadC...1101`
2. appeler `mint`
3. la transaction est refusée : `OwnableUnauthorizedAccount`

Puis, revenu sur le compte propriétaire, appeler `mint` **avec l'adresse du compte 2 comme
destinataire** : la transaction passe, et le compte 2 reçoit l'exemplaire.

C'est la nuance à souligner : `onlyOwner` porte sur **celui qui appelle** la fonction
(`msg.sender`), pas sur le destinataire. Le contrat restreint le droit de **créer**, pas
celui de posséder — le comportement attendu d'une collection d'artiste, où seul l'auteur
émet mais où n'importe qui peut détenir.

Le compte 2 détient donc des exemplaires sans avoir le moindre privilège sur le contrat.

## Bonus

**L'œuvre** — vectorielle, donc nette à toute échelle. L'harmonie des couleurs est
structurelle : une seule teinte par image, les rapports de luminosité entre facettes ne
bougent pas.

**Les inscriptions** — image et métadonnées entièrement on-chain, déjà démontré au point 2 :
le contrat renvoie l'œuvre elle-même, il n'y a aucune ressource externe.

**Le site de mint** — http://localhost:8000, déjà lancé (voir la préparation).

Ce qu'il faut montrer, dans cet ordre :

1. **la galerie s'affiche sans wallet connecté** — la page lit un nœud Sepolia public.
   N'importe qui peut consulter la collection, y compris sur cette machine.
2. **cliquer sur un exemplaire** — la fenêtre de détail donne l'image en grand, le nom,
   l'artiste, la teinte et le propriétaire. C'est un second chemin pour montrer les deux
   critères de métadonnées, sans passer par la barre d'adresse.
3. **connecter MetaMask, puis minter** — la transaction part, et la galerie se met à jour
   toute seule après confirmation.
4. **basculer sur le compte 2 et recliquer** — le bouton se désactive avec un message.

   Préciser que **ce blocage est un confort d'interface, pas une sécurité** : réactiver le
   bouton depuis les outils de développement enverrait une transaction que le contrat
   rejetterait de toute façon. La protection est on-chain, l'interface ne fait que
   l'anticiper. C'est une question que le correcteur peut poser.

Mentionner aussi que la page **n'utilise aucune clé d'API** — les nœuds interrogés sont
publics — et qu'elle bascule automatiquement sur un autre nœud si le premier ne répond pas.

## Questions probables

**« Pourquoi pas IPFS, alors que le sujet le cite ? »**
Le sujet impose « distributed registry technology », et donne IPFS comme exemple entre
parenthèses. Une blockchain est un registre distribué. Avec IPFS, le token et l'image ont
des conditions de survie différentes — le token vit tant qu'Ethereum vit, l'image tant que
quelqu'un la pinne. En on-chain, c'est le même objet.

**« Ton aléatoire est prévisible. »**
Il n'y a pas d'aléatoire. La teinte est une fonction déterministe du `tokenId`, et c'est
voulu : l'exemplaire n°3 doit toujours produire la même œuvre. Ce n'est pas un tirage.

**« Pourquoi une collection et pas une œuvre unique ? »**
Pour que `ownerOf` soit démontrable sur plusieurs exemplaires détenus par des adresses
différentes, et parce que la variation de teinte fait partie de l'œuvre : les 42
exemplaires forment ensemble le cercle chromatique complet.

**« À quoi sert `renounceOwnership` ? Ce n'est pas dangereux ? »**
Elle est héritée d'`Ownable`. Si le propriétaire l'appelle, le propriétaire devient
l'adresse zéro et plus personne ne peut minter : la collection est scellée définitivement
au nombre d'exemplaires du moment. C'est assumé — c'est le moyen pour l'artiste de clore
l'édition. Elle est `onlyOwner`, donc personne d'autre ne peut la déclencher.

**« Combien ça coûte d'afficher l'image ? »**
Rien. `tokenURI` est une fonction `view` : elle est lue hors transaction. Seule la taille
du bytecode compte, et elle est très en deçà de la limite de 24 576 octets.
