//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FashionPassport} from "../src/FashionPassport.sol";

contract FashionPassportTest is Test {
    FashionPassport public passport;

    //adding fake wallets to the test
    address alice;
    address bob;

    //adding a setup function for a fresh start everytime
    function setUp() public {
        passport = new FashionPassport();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    //making the first function to test the createpassport function
    function test_CreatePassport_StoresData() public {
        vm.prank(alice);
        //alice creating and adding info to her new passport
        uint256 id = passport.createPassport("Gucci", "Horsebit Loafers", "ipfs://abc");

        //getting the id of the new passport
        //using memory to access a copy
        FashionPassport.Passport memory p = passport.getPassport(id);

        assertEq(p.brand, "Gucci");
        assertEq(p.model, "Horsebit Loafers");
        assertEq(p.metadataURI, "ipfs://abc");
    }

    //creating a test to check the setting of the owner and registrar
    function test_CreatePassport_SetsOwnerAndRegistrar() public {
        vm.prank(alice);
        uint256 id = passport.createPassport("Gucci", "Horsebit Loafers", "ipfs://abc");

        //fetching it
        FashionPassport.Passport memory p = passport.getPassport(id);

        assertEq(passport.ownerOf(id), alice);
        assertEq(p.registrar, alice);
    }

    //creating a function to check that the id are auto-increment
    function test_IdsStartAtOneAandIncrement() public {
        vm.prank(alice);
        uint256 firstId = passport.createPassport("Gucci", "Horsebit Loafers", "ipfs://abc");

        vm.prank(bob);
        uint256 secondId = passport.createPassport("Nike", "Air Max 90", "ipfs;//def");

        assertEq(firstId, 1);
        assertEq(secondId, 2);
    }

    //creating a function to check the transfer of the ownership
    function test_Transfer_ChangesOwner() public {
        //alice registers the item
        vm.prank(alice);

        uint256 id = passport.createPassport("Gucci", "Horsebit Loafers", "ipfs://abc");

        //transferring the item to bob and checking
        vm.prank(alice);
        passport.transferFrom(alice, bob, id);

        FashionPassport.Passport memory p = passport.getPassport(id);

        assertEq(passport.ownerOf(id), bob);
        assertEq(p.registrar, alice);
    }

    //creating a function to check that u cannot rever the owner when doing a transfer
    function test_RevertWhen_NotOnwerTransfers() public {
        vm.prank(alice);

        uint256 id = passport.createPassport("Gucci", "Horsebit Loafers", "ipfs://abc");

        vm.prank(bob);
        vm.expectRevert();
        passport.transferFrom(alice, bob, id);
    }
}
