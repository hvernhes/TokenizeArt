# Mint — 42 Essence

## Qui peut minter

Le mint est réservé au **propriétaire du contrat**, celui qui l'a déployé. Toute autre
adresse est refusée avec l'erreur `OwnableUnauthorizedAccount`, y compris si elle détient
déjà des exemplaires.

La collection est plafonnée à 42 exemplaires. Au-delà, `mint` échoue avec
`MaxSupplyReached`.

## Outils

| Fichier | Rôle |
|---|---|
| [`index.html`](index.html) | interface graphique : galerie des exemplaires et bouton de mint |
| [`../deployment/Essence42.abi.json`](../deployment/Essence42.abi.json) | l'interface nécessaire pour appeler `mint` depuis n'importe quel client |
| [`../code/Essence42.sol`](../code/Essence42.sol) | la source, à charger dans Remix pour interagir |

Aucun fichier de ce dossier ne contient de clé ni de mot de passe : la signature se fait
dans MetaMask, et les nœuds interrogés par la page sont des points d'accès publics sans
clé d'API.

## Minter via l'interface graphique

### Lancer la page

**La page doit être servie en HTTP. Ne pas l'ouvrir par double-clic.**

```
cd mint
python3 -m http.server 8000
```

Puis ouvrir **http://localhost:8000**. `Ctrl+C` pour arrêter le serveur.

Cette contrainte n'est pas cosmétique : ouverte en `file://`, la page n'a pas d'origine
valide. MetaMask refuse alors de s'y connecter, et son interface peut même planter en
tentant d'afficher un site connecté sans origine. `python3` est présent d'office sur macOS
et sur les machines de l'école, il n'y a rien à installer.

### Utiliser la page

La galerie et l'état du contrat s'affichent **sans wallet** : la page lit un nœud Sepolia
public. N'importe qui peut donc consulter la collection.

Pour minter :

1. *Connecter MetaMask* — la page propose la bascule vers Sepolia si nécessaire
2. renseigner l'adresse destinataire (pré-remplie avec le compte connecté)
3. *Minter*, puis confirmer dans MetaMask

Le bouton est désactivé si le compte connecté n'est pas le propriétaire du contrat, avec un
message explicite. **Ce blocage est un confort d'interface, pas une sécurité** : réactiver
le bouton depuis les outils de développement enverrait une transaction que le contrat
rejetterait avec `OwnableUnauthorizedAccount`. La protection est on-chain.

Cliquer sur un exemplaire de la galerie ouvre une fenêtre de détail : image agrandie, nom,
description, identifiant, teinte, artiste, propriétaire et lien vers Blockscout.

### Comment la page fonctionne

Deux connexions distinctes, et c'est le point de conception à retenir :

| | Connexion utilisée |
|---|---|
| Lire l'état et la galerie | un nœud Sepolia public — aucun wallet requis |
| Minter | MetaMask, qui signe la transaction |

Trois points d'accès publics sont essayés dans l'ordre : si le premier ne répond pas, la
page bascule sur le suivant. Elle reste donc utilisable si l'un d'eux est en panne.

Les erreurs `OwnableUnauthorizedAccount` et `MaxSupplyReached` sont déclarées dans l'ABI
utilisée par la page, ce qui permet de les traduire en messages lisibles plutôt que
d'afficher une erreur brute. Sont également traités : le refus dans MetaMask, une adresse
destinataire invalide, l'absence de wallet et un mauvais réseau.

## Minter via Remix (sans interface graphique)

1. Ouvrir [remix.ethereum.org](https://remix.ethereum.org), y placer `Essence42.sol` et le
   compiler.
2. Onglet **Deploy & Run Transactions**, environnement **Injected Provider — MetaMask**,
   MetaMask sur **Sepolia**, avec le compte propriétaire sélectionné.
3. Dans la section *At Address*, coller l'adresse du contrat déployé et valider. Le contrat
   apparaît alors dans *Deployed Contracts*.
4. Déplier le contrat, renseigner le champ `to` de la fonction `mint` avec l'adresse
   destinataire, puis exécuter et confirmer dans MetaMask.

Le premier exemplaire porte l'identifiant `0`, les suivants s'incrémentent.

## Vérifier le résultat

Après le mint, dans Remix (lectures gratuites, sans transaction) :

| Appel | Ce qu'il montre |
|---|---|
| `totalMinted()` | le nombre d'exemplaires existants |
| `ownerOf(<id>)` | le propriétaire de l'exemplaire |
| `hueOf(<id>)` | la teinte attribuée |
| `tokenURI(<id>)` | les métadonnées complètes, image comprise |

Visuellement : `https://eth-sepolia.blockscout.com/token/<adresse>/instance/<id>`

## Exemplaires mintés sur le contrat de référence

Contrat `0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72`, propriétaire
`0x93Bf190F82D00cbC103f32FaCc32f15a63D233f9`.

| Exemplaire | Teinte | Aperçu |
|---|---|---|
| `0` | 200 — bleu | https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/0 |
| `1` | 311 — magenta | https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/1 |
| `2` | 62 — jaune-vert | https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72/instance/2 |

Les trois teintes sont volontairement éloignées : voir l'explication du pas chromatique
dans le [README](../README.md).
