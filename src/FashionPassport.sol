//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//FashionPassport contract stores a clothing  item
//anyone can register an itme and the ownership transfers on resale, building a verifiable on-chain ownership histroy
contract FashionPassport is ERC721 {
    //creating a struct to basically keep track of the items details
    //so brand,model, registrar, owner, createdAt and the metadataURI
    struct Passport {
        string brand;
        string model;
        address registrar;
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

    //adding a constructore to run once at deployement so that it passes the collection name + ticker to the erc721
    constructor() ERC721("Fashion Passport", "FASH") {}

    //making a function to register a new clothing item and then we return the passport id
    function createPassport(string memory _brand, string memory _model, string memory _metadataURI)
        public
        returns (uint256)
    {
        //adding 1 first so the first passport is 1 then getting the value
        //so the first id is never 0
        uint256 id = ++nextPassportId;

        //pointing to the slot
        //p is a nickname and its storage so everythins we write to p is written for real
        Passport storage p = passports[id];

        p.brand = _brand;
        p.model = _model;
        p.registrar = msg.sender;
        p.createdAt = block.timestamp;
        p.metadataURI = _metadataURI;

        //the NFT replaces the p.owner set to the msg.sender so
        //openzepellin has their own table and emits the transfer so we use safe to check
        _safeMint(msg.sender, id);

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

    //creating a function so that metamask and opensea call to tfind the image
    function tokenURI(uint256 _id) public view override returns (string memory) {
        //reverting if the owner doesnt exist calling the already existing function
        _requireOwned(_id);
        return passports[_id].metadataURI;
    }
}
