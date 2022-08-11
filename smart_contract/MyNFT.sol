// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 { 

    event Minted(uint tokenId, address minter);
    mapping(address => uint[]) public ownerTokens;
    uint public totalSupply;
    uint public maxSupply = 5;

    constructor() ERC721("MyNFT", "MYNFT") {}

    function ownerTokensLength(address _owner) external view returns(uint) {
        return ownerTokens[_owner].length;
    }

    function mint() external payable {
        require(msg.value >= 1000000000000000000, "insufficient payment!");
        require(totalSupply < maxSupply, "max supply reached!");
        uint tokenId = ++totalSupply;
        _safeMint(msg.sender, tokenId);
        ownerTokens[msg.sender].push(tokenId);

        emit Minted(tokenId, msg.sender);
    }

    function _baseURI() internal pure override returns(string memory) {
        return "https://ipfs.punkapes.cash/ipfs/QmYKzH4bP6rFg3sxmEb51VnURFuE8Jk9VTCtVWfEM8QRBi/";
    }
}