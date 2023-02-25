// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistanceokenURI();
error WithdrawTransfer();


contract NFT is ERC721,Ownable {
    using Strings for uint256;
    string public baseURI;
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.02 ether;
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name,_symbol) {
        baseURI = _baseURI;
    }

    function mintTo(address reciever) public payable returns(uint256) {
        if(msg.value != MINT_PRICE){
            revert MintPriceNotPaid();
        }
        uint256 newItemId = ++currentTokenId;
        if(newItemId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(reciever,newItemId);
        return(newItemId);

    }

    function tokenURI(uint256 id) 
    public view virtual override returns(string memory) {
        if(ownerOf(id) == address(0)){
            revert NonExistanceokenURI();
        }
        return(bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI,id.toString())) : "");
        
    }


    function withdrawPayments(address payable addr) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = addr.call{value:balance}("");
        if(!transferTx) {
            revert WithdrawTransfer();
        }
    }

}