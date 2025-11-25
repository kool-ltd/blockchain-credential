// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol"; // Available in OpenZeppelin 4.5+

contract BlockchainCredential is ERC1155, Ownable {
    using Strings for uint256;

    struct CredentialData {
        string receiverName;
        string talkTitle;
        string organizationName; // New
        string eventDate;
        string issuerName;
        string issuerTitle;      // New
        string signatureUrl;     // New
        uint256 timestamp;
    }

    mapping(uint256 => CredentialData) private tokenData;

    // We don't need the URL in the constructor anymore because we generate it dynamically
    constructor() ERC1155("") Ownable(msg.sender) {}

    function name() public pure returns (string memory) {
        return "Kool Credentials";
    }

    // function symbol() public pure returns (string memory) {
    //     return "BCCD";
    // }

    function mint(
        address to,
        uint256 id,
        string memory receiverName,
        string memory talkTitle,
        string memory organizationName,
        string memory eventDate,
        string memory issuerName,
        string memory issuerTitle,
        string memory signatureUrl
    ) public onlyOwner {
        tokenData[id] = CredentialData({
            receiverName: receiverName,
            talkTitle: talkTitle,
            organizationName: organizationName,
            eventDate: eventDate,
            issuerName: issuerName,
            issuerTitle: issuerTitle,
            signatureUrl: signatureUrl,
            timestamp: block.timestamp
        });
        _mint(to, id, 1, "");
    }

    // === Getters ===
    function getData(uint256 id) public view returns (CredentialData memory) {
        return tokenData[id];
    }

    // === On-Chain Metadata Generation ===
    // This fixes the issue of the image not showing up in wallets.
    // It generates a JSON string encoded in Base64.
    function uri(uint256 id) public view override returns (string memory) {
        CredentialData memory data = tokenData[id];

        // We use the template image as the NFT preview image
        string memory image = "https://raw.githubusercontent.com/francispun/blockchain-credential/refs/heads/main/images/badge.png";

        string memory json = string(abi.encodePacked(
            '{"name": "Certificate: ', data.receiverName, '",',
            '"description": "Certificate of Participation for ', data.talkTitle, '",',
            '"image": "', image, '",',
            '"attributes": [',
                '{"trait_type": "Receiver", "value": "', data.receiverName, '"},',
                '{"trait_type": "Organization", "value": "', data.organizationName, '"},',
                '{"trait_type": "Date", "value": "', data.eventDate, '"}',
            ']}'
        ));

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }
}
