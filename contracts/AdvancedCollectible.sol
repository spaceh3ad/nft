pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/src/v0.8/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 public fee;
    uint256 public tokenCounter;

    mapping(bytes32 => address) public requetsIdToSender;
    mapping(bytes32 => string) public requetsIdToTokenUri;

    event requestedCollectible(bytes32 requestId);

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyhash
    ) VRFConsumer(_VRFCoordinator, _LinkToken) ERC721("Doggies", "DOG") {
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
        tokenCounter = 0;
    }

    function createCollectible(uint256 userProviderSeed, string memory tokenURI)
        public
        returns (bytes32)
    {
        bytes32 requestId = requestRandomness(keyHash, fee, userProviderSeed);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        address dogOwner = requetsIdToSender[requestId];
        string memory tokenURI = requetsIdToTokenUri[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        
    }
}
