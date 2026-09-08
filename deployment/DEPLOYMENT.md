# Déploiement — 42 Essence

## Résultat

| | |
|---|---|
| Contrat | `Essence42` |
| Adresse | `0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72` |
| Réseau | Sepolia (testnet Ethereum), chainId `11155111` |
| Nom / symbole | 42 Essence / `E42` |
| Propriétaire | `0x93Bf190F82D00cbC103f32FaCc32f15a63D233f9` |
| Date | 2026-09-07 |

Liens :

- code et transactions : https://sepolia.etherscan.io/address/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72
- collection et images : https://eth-sepolia.blockscout.com/token/0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72

Le contrat déployé est immuable. Chaque nouveau déploiement crée un contrat distinct à une
nouvelle adresse — il n'écrase jamais le précédent.

## Outils

| Fichier | Rôle |
|---|---|
| [`../code/Essence42.sol`](../code/Essence42.sol) | la source à compiler et déployer |
| `Essence42.abi.json` | l'interface du contrat, nécessaire pour l'appeler depuis un script, une page web ou un explorateur |

Le déploiement se fait avec **Remix IDE**. Ce choix a une conséquence directe sur ce
dossier : il n'y a **aucun fichier de configuration contenant un secret**. La clé privée
reste dans MetaMask et ne transite jamais par le dépôt.

## Réglages de compilation

| | |
|---|---|
| Compilateur | Solidity 0.8.20 ou supérieur |
| Optimisation | non activée |
| Dépendances | OpenZeppelin Contracts v5 (résolues automatiquement par Remix depuis les imports) |

La version 0.8.20 est un minimum imposé par OpenZeppelin v5 : en dessous, les imports ne
compilent pas.

## Procédure

1. Ouvrir [remix.ethereum.org](https://remix.ethereum.org) et y créer un fichier
   `Essence42.sol` contenant la source.
2. Onglet **Solidity Compiler** : choisir la version 0.8.20 ou supérieure, puis *Compile*.
3. Dans MetaMask, sélectionner le réseau **Sepolia**. L'adresse doit disposer de
   SepoliaETH ; sinon, passer par un faucet.
4. Onglet **Deploy & Run Transactions** : environnement **Injected Provider — MetaMask**
   (libellé *Browser Extension* selon les versions).

   Vérifier que le champ `ACCOUNT` affiche bien un solde non nul. Un solde à zéro alors que
   MetaMask en affiche un signale que Remix est connecté à un autre réseau : MetaMask
   associe un réseau à chaque site connecté, et ne suit pas toujours un changement à chaud.
5. Sélectionner le contrat `Essence42` et cliquer *Deploy*. Le constructeur ne prend aucun
   argument : celui qui déploie devient propriétaire.
6. Confirmer dans MetaMask, puis relever l'adresse du contrat déployé.

## Vérification du code source

Remix vérifie automatiquement après déploiement, à condition qu'une clé d'API Etherscan
soit renseignée dans *Settings → Connected Services*. Sourcify, Blockscout et Routescan ne
demandent aucune clé.

État pour le contrat de référence : **vérifié partout** — Etherscan, Sourcify, Blockscout
et Routescan. Le code source est consultable directement sur chacun.

La clé Etherscan n'ayant pas été renseignée au moment du déploiement, la vérification a été
reprise après coup. Pour vérifier un contrat déjà déployé : activer le plugin **Contract
Verification** depuis le *Plugin Manager*, y sélectionner le contrat compilé, le réseau et
l'adresse.

## Remarque sur l'affichage

Etherscan n'affiche pas l'image de ce NFT, alors que Blockscout et MetaMask le font à
partir du même `tokenURI`. Les métadonnées sont au format ERC721 canonique — la limite est
du côté d'Etherscan, qui traite mal les data URI. Voir
[`../documentation/usage.md`](../documentation/usage.md).
