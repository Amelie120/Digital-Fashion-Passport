//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

//FashionPassport contract stores a clothing  item
//anyone can register an itme and the ownership transfers on resale, building a verifiable on-chain ownership histroy
contract FashionPassport {
    //creating a struct to basically keep track of the items details
    //so brand,model, registrar, owner, createdAt and the metadataURI
    struct Passport {
        string brand;
        string model;
        address registrar;
        address owner;
        uint256 createdAt;
        string metadataURI;
    }

    //now creating the mappings so every passport can be identified by a number
    mapping(uint256 id => Passport) public passports;
    //creating nextpassport variable as a counter
    uint256 public nextPassportId;

    //adding events as a receipt for the transaction log
    //so the frontend wil listen for these to rebuild the ownership history without storing an array on-chain
    event PassportCreated(
        //using index makes a field searchable
        uint256 indexed id,
        address indexed registrar,
        string brand,
        string model
    );

    event PassportTransferred(
        uint256 indexed id,
        address indexed from,
        address indexed to
    );

    //making a function to register a new clothing item and then we return the passport id
    function createPassport(
        string memory _brand,
        string memory _model,
        string memory _metadataURI
    ) public returns (uint256) {
        //adding 1 first so the first passport is 1 then getting the value
        //so the first id is never 0
        uint256 id = ++nextPassportId;

        //pointing to the slot
        //p is a nickname and its storage so everythins we write to p is written for real
        Passport storage p = passports[id];

        p.brand = _brand;
        p.model = _model;
        p.owner = msg.sender;
        p.registrar = msg.sender;
        p.createdAt = block.timestamp;
        p.metadataURI = _metadataURI;

        emit PassportCreated(id, msg.sender, _brand, _model);

        return id;
    }

    //creating a function to get the desired passport
    //making it a read only function with view
    function getPassport(uint256 _id) public view returns (Passport memory) {
        //because we used a mapping it will return a struct full of zeros
        //createdat can never be 0 so we need to check
        //so I add a require to check
        require(passports[_id].createdAt != 0, "This passport does not exist");

        return passports[_id];
    }

    //need a function for transferring the passport to the new owner
    //so fox example when the item is resold
    function transferPassport(uint256 _id, address _to) public {
        Passport storage p = passports[_id];

        //checking that its valid first
        require(p.createdAt != 0, "This passport does not exist");
        require(p.owner == msg.sender, "Not the owner");
        require(_to != address(0), "Cannot transfer to this zero address");

        //setting the address so the event can report it
        address from = p.owner;

        p.owner = _to;

        emit PassportTransferred(_id, from, _to);
    }
}
