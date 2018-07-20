pragma solidity ^0.4.24;
import "./MineorityOwnership.sol";
import "./utils/oraclizeAPI_0.5.sol";
import "./utils/strings.sol";


contract MineorityMarket is MineorityOwnership,usingOraclize {
    using strings for *;

    string[] public form;

    mapping(bytes32 => bool) validIds;
    mapping(bytes32 => string) queryIdToHash;
    mapping(string => string) hashToData;

    event ItReturned();

    constructor() {
        // Just for local testing
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }

    function __callback(bytes32 myid, string result) {
        require(validIds[myid]);
        require(msg.sender == oraclize_cbAddress());
        hashToData[queryIdToHash[myid]] = result;
        delete validIds[myid];
        emit ItReturned();
    }

    function queryIPFS(string _hash) public payable {
        bytes32 queryId = oraclize_query("IPFS", _hash);
        queryIdToHash[queryId] = _hash;
        validIds[queryId] = true;
    }

    function res(string _hash) public view returns(string) {
        return hashToData[_hash];
    }

    function get(uint i) public view returns(string) {
        return form[i];
    }

    function parse(string _hash) public {
        var s = hashToData[_hash].toSlice();
        var delim = ".".toSlice();
        form = new string[](s.count(delim) + 1);
        for(uint i = 0; i < form.length; i++) {
            form[i] = s.split(delim).toString();
        }
    }

    // Basically we'll have a mapping hash => data from ipfs,
    // comparing data with something else

    function executeOrder(address[] vendors, uint256[] prices) public payable {
        // Query IPFS
        require(msg.value >= parseInt(form[0]));
        bytes32 checkHash = keccak256("570000000000000000.ffe1b32a483abd02e966296fbc1904ff50f4beb323d6ec23cb6ecd2360ae90a4.3b086c9231fe2ffff98ae089d7b60efacedc3686a537272bf56ebbf0217a2f95");
        // Padazhdat eba

        // ...

        // Parse into 3 parts

        // Verify everything, calculate and send everything to everyone
    }

    function check() public returns(bytes32) {
        return keccak256(strConcat("0xf17f52151ebef6c7334fad080c5704d77216b732","570000000000000000"));
    }



    function _mint(string _dataHash) internal {
        // after payment confirmed

        Token memory _token = Token({
            dataHash: _dataHash
        });

        uint256 _tokenId = allTokens.length;
        // Just to make sure
        require(_tokenId <= 4294967295);
        allTokens.push(_token); 

        addTokenTo(msg.sender,_tokenId);
    }




    function() public payable {}
}
