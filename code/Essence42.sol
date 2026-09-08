// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title 42 Essence
/// @author hvernhes
/// @notice Collection de 42 eclats d'essence. L'image et les metadonnees sont
///         generees integralement par le contrat : aucune dependance externe,
///         ni IPFS ni serveur. Ce que possede le detenteur est l'oeuvre elle-meme.
contract Essence42 is ERC721, Ownable {
    using Strings for uint256;

    /// @notice Nombre maximal d'exemplaires. Constante : figee a la compilation.
    uint256 public constant MAX_SUPPLY = 42;

    /// @dev Pas de progression sur le cercle chromatique. Premier avec MAX_SUPPLY.
    uint256 private constant HUE_STRIDE = 13;

    /// @dev Teinte du premier exemplaire : le bleu de l'essence d'origine.
    uint256 private constant HUE_ORIGIN = 200;

    /// @dev Identifiant du prochain exemplaire. Le premier token porte l'id 0.
    uint256 private _nextTokenId;

    /// @notice Levee quand la collection est complete.
    error MaxSupplyReached();

    constructor() ERC721("42 Essence", "E42") Ownable(msg.sender) {}

    /// @notice Cree un exemplaire et l'attribue a `to`.
    /// @dev Reserve au proprietaire du contrat.
    function mint(address to) external onlyOwner {
        if (_nextTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        _safeMint(to, _nextTokenId++);
    }

    /// @notice Nombre d'exemplaires deja mintes.
    function totalMinted() external view returns (uint256) {
        return _nextTokenId;
    }

    /// @notice Teinte HSL d'un exemplaire : 42 tokens, 42 teintes distinctes.
    /// @dev HUE_STRIDE (13) est premier avec MAX_SUPPLY (42). Multiplier par 13
    ///      modulo 42 est donc une bijection : les 42 exemplaires occupent les 42
    ///      positions du cercle, une chacune, mais dans un ordre qui eloigne
    ///      fortement les exemplaires consecutifs. Une progression lineaire les
    ///      aurait rendus indistinguables deux a deux (8 degres d'ecart).
    function hueOf(uint256 tokenId) public pure returns (uint256) {
        uint256 position = (tokenId * HUE_STRIDE) % MAX_SUPPLY;
        return (HUE_ORIGIN + (position * 360) / MAX_SUPPLY) % 360;
    }

    /// @dev Assemble le SVG. Seule la teinte varie ; la geometrie est figee.
    function _buildSVG(uint256 tokenId) internal pure returns (string memory) {
        string memory h = hueOf(tokenId).toString();

        string memory background = string.concat(
            '<rect width="100" height="100" fill="hsl(', h, ',40%,6%)"/>'
        );

        string memory shards = string.concat(
            '<path d="M24 44 L31 36 L32 49 Z" fill="hsl(', h, ',60%,60%)"/>',
            '<path d="M74 32 L80 41 L71 45 Z" fill="hsl(', h, ',60%,55%)"/>',
            '<path d="M68 60 L76 65 L69 70 Z" fill="hsl(', h, ',60%,50%)"/>'
        );

        string memory gem = string.concat(
            '<path d="M50 10 L38 36 L50 43 Z" fill="hsl(', h, ',55%,55%)"/>',
            '<path d="M50 10 L62 36 L50 43 Z" fill="hsl(', h, ',70%,82%)"/>',
            '<path d="M38 36 L44 58 L50 72 L50 43 Z" fill="hsl(', h, ',60%,30%)"/>',
            '<path d="M62 36 L56 58 L50 72 L50 43 Z" fill="hsl(', h, ',55%,44%)"/>'
        );

        string memory label = string.concat(
            '<text x="50" y="93" font-size="16" text-anchor="middle" letter-spacing="2"',
            ' font-family="sans-serif" fill="hsl(', h, ',75%,80%)">42</text>'
        );

        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">',
            background, shards, gem, label,
            '</svg>'
        );
    }

    /// @notice Metadonnees du token, encodees en data URI : le wallet n'a rien
    ///         a telecharger, tout est renvoye par le contrat.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory json = string.concat(
            '{"name":"42 Essence #', tokenId.toString(), '",',
            '"description":"',
            "A shard of essence, generated entirely on-chain. Where Tokenizer made ",
            "essence a fungible currency, 42 Essence makes it a unique object.",
            '",',
            '"attributes":[',
                '{"trait_type":"artist","value":"hvernhes"},',
                '{"trait_type":"hue","value":', hueOf(tokenId).toString(), '}',
            '],',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(_buildSVG(tokenId))),
            '"}'
        );

        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }
}
