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

Sur la session du correcteur il n'y a pas mon extension MetaMask. Tout ce qui demande une
signature passe donc par **WalletConnect et mon téléphone**. Les étapes ci-dessous sont
dans l'ordre : chacune dépend de la précédente.

*(Préparation en lettres A à H, démonstration en chiffres 1 à 8 — pour ne pas confondre les
deux séries en pleine soutenance.)*

### A. Le dépôt

Cloné depuis GitHub et à jour.

### B. MetaMask mobile

Compte 1 — `0x93Bf190F82D00cbC103f32FaCc32f15a63D233f9` — sélectionné, avec du SepoliaETH.

**Vérifier l'URL RPC du réseau Sepolia.** C'est le point qui a fait échouer deux
répétitions, sur Tokenizer puis sur TokenizeArt : le réseau s'appelle bien « Sepolia » dans
l'application, mais pointe vers un nœud mort. Les appels partent, reviennent d'ailleurs, et
Remix répond `no code found at address` sur un contrat qui existe pourtant.

URL qui fonctionne, chaîne `11155111`, symbole `ETH` :

```
https://ethereum-sepolia-rpc.publicnode.com
```

### C. Remix — l'adresse exacte

```
https://remix.ethereum.org/#nomigrationredirect&lang=en
```

Deux raisons à cette URL précise :

- le projet a déménagé en septembre 2026 vers `app.remix.live`, où **WalletConnect est
  cassé** : sa liste de domaines autorisés n'a pas suivi, le QR code n'est jamais généré et
  l'erreur « Invalid App Configuration » apparaît brièvement
- `remix.ethereum.org` **redirige automatiquement** vers ce nouveau domaine ; le fragment
  `#nomigrationredirect` est ce qui l'en empêche

C'est un refus de migration, donc par nature temporaire. **À revérifier la veille** : si
Remix cesse de l'honorer, WalletConnect devient inutilisable et il faut un autre chemin
pour signer.

### D. Charger et compiler

`code/Essence42.sol` chargé dans Remix, compilé en 0.8.20 ou plus.

Vérifier que **`Essence42` est sélectionné** dans la liste des contrats de l'onglet
*Deploy & Run*. Sans contrat sélectionné, le bouton *At Address* reste grisé — Remix a
besoin de l'ABI issue de la compilation pour savoir quoi appeler.

### E. Connecter WalletConnect

Environnement **WalletConnect**, QR code scanné avec MetaMask mobile. Sur l'écran
d'approbation, **ne cocher que Sepolia**.

**Le réseau et le compte sont figés à la création de la session.** Changer de compte dans
MetaMask ne change rien côté Remix : il faut déconnecter la session, en relancer une, et
rescanner le QR code avec l'autre compte sélectionné.

C'est pour ça que la démonstration groupe tout ce qui concerne le compte 1 (points 7 et 8),
et ne bascule qu'une seule fois vers le compte 2, à la toute fin.

### F. Attacher le contrat et vérifier le réseau

*At Address* avec `0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72`, puis appeler
**`MAX_SUPPLY()` — doit renvoyer `42`**.

C'est le **seul** test fiable du réseau. Le solde affiché ne prouve rien : cette adresse
affiche 0 sur Ethereum comme sur Sepolia tant qu'elle est peu alimentée. Si `MAX_SUPPLY()`
répond 42, le contrat est bien là, donc le réseau est le bon.

### G. Lancer le site de mint

Voir les commandes en tête de ce fichier. Ouvert sur http://localhost:8000.

**Jamais par double-clic** : en `file://` la page n'a pas d'origine valide, MetaMask refuse
de s'y connecter et son interface peut planter.

### H. Ouvrir les onglets Blockscout

La collection :

```
https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72
```

Les trois exemplaires montrés au point 1 — teintes consécutives, nettement différentes :

```
https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/0
https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/1
https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/2
```

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
documentation**. Le dire avant qu'il ne cherche, pour éviter le malentendu :

> Sur les quatorze fonctions documentées, cinq sont écrites dans `Essence42.sol` —
> `MAX_SUPPLY`, `mint`, `totalMinted`, `hueOf` et `tokenURI`. Les neuf autres sont celles du
> standard, héritées d'`ERC721` et d'`Ownable` : elles n'apparaissent pas dans mon fichier,
> elles sont dans le code d'OpenZeppelin dont il hérite.

La colonne « Origine » des tableaux d'`usage.md` indique la provenance de chacune.

C'est un choix assumé : réimplémenter un standard, c'est réintroduire des failles que des
années d'audit ont éliminées.

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

Une session WalletConnect ne permet pas de changer de compte en cours de route. Le point 8
est donc organisé pour **n'avoir qu'une seule reconnexion**, placée à la fin : tout ce qui
demande le compte 1 d'abord, le compte 2 ensuite.

### 8a. Avec le compte 1 (déjà connecté)

1. **`mint`** avec l'adresse du correcteur, ou la tienne → la transaction passe.
   Confirmer avec `ownerOf` sur le nouvel identifiant, et le lien Blockscout de
   l'exemplaire fraîchement créé.
2. **`mint` avec l'adresse du compte 2 `0xDadC...1101` comme destinataire** → la
   transaction passe aussi.

   C'est la nuance à souligner : `onlyOwner` porte sur **celui qui appelle** la fonction
   (`msg.sender`), pas sur le destinataire. Le contrat restreint le droit de **créer**, pas
   celui de posséder — le comportement attendu d'une collection d'artiste, où seul l'auteur
   émet, mais où n'importe qui peut détenir.

### 8b. Reconnexion sur le compte 2

Déconnecter la session WalletConnect, en relancer une depuis Remix, et rescanner le QR code
avec le **compte 2** sélectionné dans MetaMask mobile.

### 8c. Avec le compte 2 — la démonstration de privilèges

Appeler **`mint`** : la transaction est **refusée**, avec `OwnableUnauthorizedAccount`.

C'est le point « ownership and privileges » de la fiche. Et il tombe au bon moment : le
compte 2 détient des exemplaires — on vient de lui en envoyer un — sans avoir pour autant
le moindre privilège sur le contrat.

#### MetaMask va refuser pour « fonds insuffisants » — abaisser la limite de gas

C'est un effet de bord, pas un vrai manque de fonds, et il faut le savoir à l'avance.

Une transaction vouée à échouer ne peut pas être estimée. Le wallet se rabat alors sur une
limite de gas très élevée, proche du maximum d'un bloc, et compare le solde à **ce
plafond** : 30 millions de gas à 1 gwei, c'est 0,03 ETH. D'où le refus, alors que le coût
réel est infime.

**La parade :** dans les réglages avancés de la transaction, fixer la limite de gas à
**100 000**. La vérification de solde porte alors sur un montant négligeable, la
transaction part, et échoue pour de bon — avec son motif.

Mesuré en répétition : l'échec a consommé **24 510 gas**, soit environ 0,000025 ETH. Mille
fois moins que ce que le wallet exigeait d'avoir en réserve.

#### La preuve permanente, si rien ne passe en direct

Une transaction de refus a été faite en répétition et reste consultable :

```
https://eth-sepolia.blockscout.com/tx/0xa7a4844364ef2b934954ed41b19f27ca34353514ab7c67ec7dd145efe8a2fca2
```

Émise par le compte 2 vers un contrat `Essence42`, statut en échec, motif
`OwnableUnauthorizedAccount` décodé et affiché. Si MetaMask bloque devant le correcteur, ce
lien montre exactement ce qu'on cherchait à démontrer — publiquement et de façon permanente.

## Bonus

**L'œuvre** — vectorielle, donc nette à toute échelle. L'harmonie des couleurs est
structurelle : une seule teinte par image, les rapports de luminosité entre facettes ne
bougent pas.

**Les inscriptions** — image et métadonnées entièrement on-chain, déjà démontré au point 2 :
le contrat renvoie l'œuvre elle-même, il n'y a aucune ressource externe.

**Le site de mint** — http://localhost:8000, déjà lancé (voir la préparation).

Sur la session du correcteur, la galerie s'affiche mais **le bouton de mint ne peut pas
fonctionner** : il lui faut un wallet injecté dans le navigateur, et il n'y a pas
d'extension là-bas. WalletConnect n'y change rien, la page ne l'implémente pas.

Ce qu'il faut montrer, dans cet ordre :

1. **la galerie s'affiche sans aucun wallet** — la page lit un nœud Sepolia public.
   N'importe qui peut consulter la collection, depuis n'importe quelle machine.
2. **cliquer sur un exemplaire** — la fenêtre de détail donne l'image en grand, le nom,
   l'artiste, la teinte et le propriétaire. C'est un second chemin pour montrer les deux
   critères de métadonnées, sans passer par la barre d'adresse.
3. **l'interface de mint elle-même** — le bouton, le champ destinataire, et le message
   affiché quand le compte connecté n'est pas propriétaire.
4. **la connexion du wallet depuis mon ordinateur**, avec l'extension — le seul moment où
   je me sers de ma machine. Le mint en direct, lui, a déjà été fait au point 8 via Remix.

Préciser que **le bouton désactivé est un confort d'interface, pas une sécurité** :
réactiver le bouton depuis les outils de développement enverrait une transaction que le
contrat rejetterait de toute façon. La protection est on-chain, l'interface ne fait que
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
