// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NameRegistry {
    struct NameRecord {
        address owner;
        string name;
        string data;
        bool forSale;
        uint256 price;
    }

    mapping(string => NameRecord) private records;
    mapping(address => string[]) private ownedNames;

    event NameRegistered(string indexed name, address indexed owner);
    event NameUpdated(string indexed name, string data);
    event NameTransferred(string indexed name, address indexed oldOwner, address indexed newOwner);
    event NameForSale(string indexed name, uint256 price);
    event NameSold(string indexed name, address indexed oldOwner, address indexed newOwner, uint256 price);

    function register(string memory name) public {
        require(records[name].owner == address(0), "Name already registered");
        records[name] = NameRecord(msg.sender, name, "", false, 0);
        ownedNames[msg.sender].push(name);
        emit NameRegistered(name, msg.sender);
    }

    function updateData(string memory name, string memory data) public {
        require(records[name].owner == msg.sender, "Not the owner");
        records[name].data = data;
        emit NameUpdated(name, data);
    }

    function transfer(string memory name, address to) public {
        require(records[name].owner == msg.sender, "Not the owner");
        records[name].owner = to;
        removeFromOwnedNames(msg.sender, name);
        ownedNames[to].push(name);
        emit NameTransferred(name, msg.sender, to);
    }

    function setForSale(string memory name, uint256 price) public {
        require(records[name].owner == msg.sender, "Not the owner");
        records[name].forSale = true;
        records[name].price = price;
        emit NameForSale(name, price);
    }

    function buy(string memory name) public payable {
        NameRecord storage record = records[name];
        require(record.forSale, "Name not for sale");
        require(msg.value >= record.price, "Insufficient payment");

        address oldOwner = record.owner;
        record.owner = msg.sender;
        record.forSale = false;
        record.price = 0;

        removeFromOwnedNames(oldOwner, name);
        ownedNames[msg.sender].push(name);

        payable(oldOwner).transfer(msg.value);
        emit NameSold(name, oldOwner, msg.sender, msg.value);
    }

    function getRecord(string memory name) public view returns (address owner, string memory data, bool forSale, uint256 price) {
        NameRecord storage record = records[name];
        return (record.owner, record.data, record.forSale, record.price);
    }

    function getOwnedNames(address owner) public view returns (string[] memory) {
        return ownedNames[owner];
    }

    function removeFromOwnedNames(address owner, string memory name) private {
        string[] storage names = ownedNames[owner];
        for (uint i = 0; i < names.length; i++) {
            if (keccak256(bytes(names[i])) == keccak256(bytes(name))) {
                names[i] = names[names.length - 1];
                names.pop();
                break;
            }
        }
    }
}