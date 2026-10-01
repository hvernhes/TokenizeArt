# Utilisation — 42 Essence

## Ce qu'est ce NFT

Une collection ERC721 de 42 exemplaires au maximum, déployée sur Sepolia. Chaque
exemplaire est un éclat de cristal facetté surmontant le nombre 42, dans une teinte qui
lui est propre.

La particularité : **l'image et les métadonnées ne sont stockées nulle part ailleurs que
dans le contrat**. Il n'y a ni fichier, ni serveur, ni IPFS. Quand un wallet demande à quoi
ressemble l'exemplaire n°3, le contrat construit le SVG et le renvoie sur-le-champ.

Contrat de référence : `0x22E8fd2682AF5c9a72b6942cd82dB7F8f778da72`

## Les fonctions

Le contrat hérite d'`ERC721` et d'`Ownable`, deux contrats d'OpenZeppelin. Une partie des
fonctions ci-dessous est donc **héritée** et n'apparaît pas dans `Essence42.sol` : elle
existe dans le code dont il hérite. La colonne « Origine » le précise pour chacune.

### Lecture — gratuites, sans transaction

| Fonction | Ce qu'elle renvoie | Origine |
|---|---|---|
| `name()` | `42 Essence` | `ERC721` |
| `symbol()` | `E42` | `ERC721` |
| `MAX_SUPPLY()` | `42` — le plafond, inscrit dans le code | **`Essence42`** |
| `totalMinted()` | le nombre d'exemplaires déjà créés | **`Essence42`** |
| `owner()` | le propriétaire du contrat, seul habilité à minter | `Ownable` |
| `ownerOf(tokenId)` | le propriétaire d'un exemplaire | `ERC721` |
| `balanceOf(address)` | le nombre d'exemplaires détenus par une adresse | `ERC721` |
| `hueOf(tokenId)` | la teinte HSL attribuée à un exemplaire, de 0 à 359 | **`Essence42`** |
| `tokenURI(tokenId)` | les métadonnées complètes, image comprise | **`Essence42`**, redéfinit celle d'`ERC721` |

`ownerOf` et `tokenURI` échouent sur un identifiant jamais minté : le contrat refuse de
répondre pour un exemplaire qui n'existe pas.

### Écriture — nécessitent une transaction

| Fonction | Qui peut l'appeler | Origine |
|---|---|---|
| `mint(address to)` | **le propriétaire seul** | **`Essence42`** |
| `transferFrom(from, to, tokenId)` | le propriétaire de l'exemplaire, ou une adresse qu'il a autorisée | `ERC721` |
| `safeTransferFrom(from, to, tokenId)` | idem, avec vérification du destinataire | `ERC721` |
| `approve(to, tokenId)` | le propriétaire de l'exemplaire | `ERC721` |
| `setApprovalForAll(operator, bool)` | tout détenteur | `ERC721` |

`safeTransferFrom` vérifie, quand le destinataire est un contrat, qu'il sait recevoir des
NFT. Sans cette vérification, un envoi vers un contrat non prévu pour cela rendrait
l'exemplaire définitivement irrécupérable.

## Lire les métadonnées

`tokenURI(0)` renvoie une chaîne de cette forme :

```
data:application/json;base64,eyJuYW1lIjoiNDIgRXNzZW5jZSAjMCIs...
```

Collée dans la barre d'adresse d'un navigateur, elle affiche le JSON :

```json
{
  "name": "42 Essence #0",
  "description": "A shard of essence, generated entirely on-chain. ...",
  "attributes": [
    { "trait_type": "artist", "value": "hvernhes" },
    { "trait_type": "hue", "value": 200 }
  ],
  "image": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0i..."
}
```

Le champ `image`, collé à son tour dans la barre d'adresse, affiche l'œuvre.

Il y a donc **deux encodages imbriqués** : le SVG est encodé pour tenir dans le champ
`image`, puis le JSON entier est encodé à son tour. Le wallet décode la première couche,
lit le champ `image`, décode la seconde, et affiche.

## Afficher le NFT

| Où | Résultat |
|---|---|
| **Blockscout** — `https://eth-sepolia.blockscout.com/token/<adresse>/instance/<id>` | l'image s'affiche |
| **Extension MetaMask** — importer le contrat depuis l'onglet NFT | l'image s'affiche |
| Etherscan | **n'affiche pas l'image** |
| MetaMask mobile | n'affiche pas les NFT de testnet |
| OpenSea | service testnet fermé |

Etherscan est bâti pour aller *télécharger* une image à une URL, puis la mettre en cache.
Un SVG embarqué en data URI n'est pas une ressource à télécharger. Les métadonnées sont
pourtant au format ERC721 canonique — c'est la même chaîne exactement que Blockscout et
MetaMask savent lire. La limite est du côté d'Etherscan.

Pour une démonstration visuelle, utiliser **Blockscout** : c'est une simple URL, elle
fonctionne depuis n'importe quel navigateur sans installer quoi que ce soit.

## Comment fonctionne la variation des teintes

```solidity
function hueOf(uint256 tokenId) public pure returns (uint256) {
    uint256 position = (tokenId * HUE_STRIDE) % MAX_SUPPLY;
    return (HUE_ORIGIN + (position * 360) / MAX_SUPPLY) % 360;
}
```

`HUE_STRIDE` vaut 13, `MAX_SUPPLY` vaut 42. Les deux nombres n'ont aucun diviseur commun,
donc multiplier par 13 modulo 42 est une **bijection** : en parcourant les 42 exemplaires,
on visite les 42 positions du cercle chromatique, une fois chacune.

L'intérêt par rapport à une progression linéaire — `tokenId * 360 / 42` — est que les
exemplaires consécutifs sont éloignés. En linéaire, deux exemplaires voisins n'auraient été
séparés que de 8 degrés, indistinguables à l'œil.

`HUE_ORIGIN` vaut 200 et décale l'ensemble pour que l'exemplaire n°0 soit bleu, comme
l'essence d'origine.

Le calcul est **déterministe** : l'exemplaire n°3 aura toujours la même teinte, sur
n'importe quel nœud, à n'importe quel moment. Aucune imprévisibilité n'est recherchée — il
ne s'agit pas d'un tirage au sort mais d'une répartition choisie.

## Minter

Voir [`../mint/MINT.md`](../mint/MINT.md).

## Déployer

Voir [`../deployment/DEPLOYMENT.md`](../deployment/DEPLOYMENT.md).
