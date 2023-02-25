// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFT.sol";

contract CounterTest is Test {
    using stdStorage for StdStorage;
    NFT private nft;
    function setUp() public {
        // deploy contract
        nft = new NFT("Foundry NFT Token","FNT","baseUri");
    }
    function testFailNoMintPricePaid() public {
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: 0.02 ether}(address(1));
    }

    function testFailMaxSupplyReached() public {
        uint256 slot = stdstore
        .target(address(nft))
        .sig("CurrentTokenId()").find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(nft),loc,mockedCurrentTokenId);
        nft.mintTo{value: 0.02 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        nft.mintTo{value: 0.02 ether}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        nft.mintTo{value: 0.02 ether}(address(1));
        uint256 slotOfNewOwner = stdstore
        .target(address(nft))
        .sig(nft.ownerOf.selector)
        .with_key(1)
        .find();
        uint160 ownerOfTokenIdOne = uint160(
            uint256(
                (vm.load(address(nft),bytes32(abi.encode(slotOfNewOwner))))
            )
        );
        assertEq(address(ownerOfTokenIdOne),address(1));
    }
    function testBalanceIncremented() public {
        nft.mintTo{value: 0.02 ether}(address(1));
        uint256 slotBalance = stdstore
        .target(address(nft))
        .sig(nft.balanceOf.selector)
        .with_key(address(1))
        .find();

        uint256 balance = uint256(vm.load(address(nft),bytes32(slotBalance)));
        assertEq(balance,1);
    }

    function testFailUnSafeContractReceiver() public {
        vm.etch(address(1),bytes("Mock code"));
        nft.mintTo{value: 0.02 ether}(address(1));
    }
      
}
