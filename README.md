# 42 Essence

Une collection de 42 NFT dont l'image et les métadonnées sont générées **intégralement par
le contrat**. Aucun fichier n'est stocké ailleurs : ni sur IPFS, ni sur un serveur. Ce que
possède le détenteur est l'œuvre elle-même, pas un lien vers elle.

Déployé sur **Sepolia**, standard **ERC721**, écrit en **Solidity**.

## Le concept

Ce projet prolonge [Tokenizer](https://github.com/hvernhes/tokenizer), où l'essence était
une **monnaie** : un ERC20 fongible, qu'on compte et qu'on échange, et dont un exemplaire
en vaut exactement un autre.

Ici, la même matière devient un **objet unique** : un ERC721, qu'on possède. Deux
exemplaires ne sont pas interchangeables — chacun a son identifiant, son propriétaire et
sa teinte.

Les deux projets montrent donc la même matière sous ses deux formes, et cette paire
illustre précisément ce qui sépare les deux standards : compter une quantité d'un côté,
tenir un registre d'objets distincts de l'autre.

L'œuvre est un éclat de cristal facetté, inspiré de la Blue Essence de *League of Legends*,
surmontant le nombre 42.

## Choix techniques

### La blockchain — Sepolia

Testnet Ethereum. Le sujet interdit d'utiliser de l'argent réel, un réseau de test est donc
obligatoire. Sepolia a été retenu pour la fiabilité de ses faucets : sur Tokenizer, le
faucet officiel de BSC Testnet s'était révélé indisponible pendant plusieurs jours, ce qui
avait bloqué le projet et imposé un changement de chaîne en cours de route.

### Le standard — ERC721

C'est le standard des jetons non fongibles sur Ethereum. Là où l'ERC20 tient un compteur
par adresse (`mapping(address => uint256)`), l'ERC721 tient un registre par objet
(`mapping(uint256 => address)`) : chaque token a une identité propre et exactement un
propriétaire. C'est ce que lit `ownerOf(tokenId)`.

### Le langage — Solidity

Imposé de fait par le choix d'Ethereum : c'est le langage des contrats de l'EVM, et celui
pour lequel existent les bibliothèques auditées dont dépend la sécurité du projet.

### La bibliothèque — OpenZeppelin

`ERC721` et `Ownable` sont hérités d'OpenZeppelin plutôt que réécrits. Réimplémenter un
standard revient à réintroduire des failles que des années d'audit ont éliminées —
notamment autour des approbations et des transferts vers des contrats.

`Base64` et `Strings` en proviennent également, pour l'encodage des métadonnées.

### L'outil — Remix IDE

Le projet tient en un contrat déployé une fois. Hardhat, utilisé sur Tokenizer, apporterait
une chaîne d'outillage (tests, scripts de déploiement, gestion de configuration) sans
contrepartie ici.

Remix a par ailleurs un avantage propre à ce projet : **la clé privée ne quitte jamais
MetaMask**. Il n'existe aucun fichier de configuration contenant un secret, donc aucun
risque d'en committer un.

### Le stockage — on-chain

C'est le choix structurant du projet.

Le sujet demande que l'image soit stockée « using distributed registry technology (IPFS,
for example) ». IPFS n'est qu'un exemple ; la contrainte porte sur la catégorie. Une
blockchain est un registre distribué — l'archétype même.

Les deux options se distinguent ainsi :

| | IPFS | on-chain |
|---|---|---|
| Ce que stocke la blockchain | un pointeur (le CID) | les octets eux-mêmes |
| Intégrité — substitution impossible | oui, le CID est le hash du contenu | oui |
| Durabilité | dépend d'un service de pinning | garantie par le consensus |
| Survie du token et de son image | **conditions différentes** | **même objet** |

Avec IPFS, le token et l'image ont des destins séparés : le token vit tant qu'Ethereum
vit, l'image tant que quelqu'un la conserve. On peut parfaitement détenir un NFT valide
qui pointe vers le néant — c'est le sort d'une part notable des collections lancées entre
2017 et 2021.

En on-chain, il n'y a rien à aller chercher. Si le token existe, l'image existe : elles
sont garanties par le même consensus, celui-là même qui établit que vous en êtes
propriétaire.

Deux autres options ont été écartées : un serveur HTTP classique (lien mort dès que le
domaine expire, et contenu remplaçable en silence) et Arweave ou Filecoin, techniquement
excellents pour la durabilité mais qui exigent de l'argent réel, ce que le sujet interdit.

### Le format — SVG

Conséquence directe du choix précédent. Écrire des octets sur la blockchain coûte de
l'ordre de 640 gas par octet, et un contrat déployé ne peut pas dépasser 24 576 octets
(EIP-170). Une image matricielle est hors de portée : un PNG de 100 Ko demanderait plus de
gas que n'en contient un bloc entier.

Le SVG est du texte, quelques centaines d'octets ici, et il est vectoriel — donc net à
n'importe quelle taille.

## L'œuvre et sa variation

La géométrie est dessinée à la main et **figée** : les mêmes facettes, la même
composition, le même 42 pour tous les exemplaires. Seule **la teinte** varie selon le
`tokenId`.

Ce choix n'est pas de la paresse, il résout un problème réel. En HSL, seule la composante
de teinte change ; la saturation et la luminosité de chaque facette restent fixes. Le
rapport entre les facettes — claire en haut, sombre en bas — est donc préservé quelle que
soit la teinte, et **rien ne peut jurer puisqu'il n'y a qu'une seule teinte dans l'image**.
L'harmonie est structurelle, pas laissée au hasard.

Le 42, lui, est tracé à part de l'illustration : il n'est jamais déformé ni recouvert.

La répartition des teintes suit un pas de 13, premier avec 42. Multiplier par 13 modulo 42
est donc une bijection : les 42 exemplaires occupent les 42 positions du cercle
chromatique, une chacune, mais dans un ordre qui éloigne fortement les exemplaires
consécutifs. Une progression linéaire les aurait séparés de 8 degrés seulement —
indistinguables à l'œil. Un décalage de 200 place le token 0 sur le bleu de l'essence
d'origine.

## Paramètres

| | |
|---|---|
| Nom | 42 Essence |
| Symbole | `E42` |
| Standard | ERC721 |
| Réseau | Sepolia, chainId `11155111` |
| Exemplaires | 42 au maximum (`MAX_SUPPLY`, constante) |
| Droit de mint | réservé au propriétaire du contrat (`onlyOwner`) |
| Artiste | `hvernhes` |

## Gouvernance et sécurité

Le mint est réservé au propriétaire du contrat. Un appel depuis n'importe quelle autre
adresse échoue avec `OwnableUnauthorizedAccount` — y compris depuis une adresse détenant
déjà des exemplaires.

`MAX_SUPPLY` est une `constant` : elle est inscrite dans le bytecode à la compilation, ne
consomme aucun emplacement de stockage, et **ne peut être modifiée par personne, pas même
par le propriétaire**. La rareté annoncée est donc vérifiable par lecture du code, elle ne
repose pas sur une promesse.

Le contrat ne détient aucun fonds et n'expose aucune fonction de retrait.

## Où c'est déployé

Contrat de référence : **`0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72`** sur Sepolia.

Détail des adresses, transactions et procédure : [`deployment/`](deployment/).
Comment interagir avec le contrat : [`documentation/usage.md`](documentation/usage.md).

## Structure du dépôt

```
README.md          ce fichier — les choix et leurs raisons
code/              le contrat Solidity
deployment/        procédure de déploiement, adresses, ABI
mint/              procédure de mint et preuves
documentation/     utilisation du NFT et déroulé de démonstration
```
