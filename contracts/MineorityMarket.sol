pragma solidity ^0.4.24;
import "./MineorityOwnership.sol";
import "./utils/oraclizeAPI_0.5.sol";
import "./utils/strings.sol";


contract MineorityMarket is MineorityOwnership,usingOraclize {
    using strings for *;

    struct Invoice {
        uint256 totalPrice;
        // vendors and whatever ???
        // uint256 expirationTime; ???
        // data about purchase ???
    }


    string[] public form;

    mapping(bytes32 => bool) validIds;
    mapping(bytes32 => string) queryIdToHash;
    mapping(string => string) hashToData;
    // Or identified by IPFS hash or by queryId or we may add ID's 
    // and map them with users
    // Btw only one invoice allowed per user
    mapping(address => Invoice) userAddressToInvoice;

    event ItReturned(string _hash);

    constructor() {
        // Just for local testing
        OAR = OraclizeAddrResolverI(0x0a143BDF026Eabaf95d3E88AbB88169674Db92f5);
    }

    function __callback(bytes32 myid, string result) {
        require(validIds[myid]);
        require(msg.sender == oraclize_cbAddress());
        hashToData[queryIdToHash[myid]] = result;
        delete validIds[myid];
        emit ItReturned(queryIdToHash[myid]);

        createInvoiceFromData(result);
    }

    function queryIPFS(string _hash) public payable {
        Invoice memory _invoice = userAddressToInvoice[msg.sender]; 
        require(_invoice.totalPrice == 0);
        bytes32 queryId = oraclize_query("IPFS", _hash, 800000);
        queryIdToHash[queryId] = _hash;
        validIds[queryId] = true;
    }



    function createInvoiceFromData(string _data) public payable {
        var s = _data.toSlice();
        var delim = ".".toSlice();
        form = new string[](s.count(delim) + 1);
        for(uint i = 0; i < form.length; i++) {
            form[i] = s.split(delim).toString();
        }

        // Take invoice
        Invoice memory _invoice = Invoice({
            totalPrice: parseInt(form[0])
            // expirationTime ???
        });

        userAddressToInvoice[parseAddr(form[2])] = _invoice;
        
    }

    function getInvoice(address _customer) view public returns(uint256) {
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        return (_invoice.totalPrice);
    }

    function removeInvoice(address _customer) public {
        delete userAddressToInvoice[_customer];
    }

    function executeOrder(address _customer,address vendors, uint256 prices) public payable {
        // Fuck who's gonna check if he pays for what he ordered
        // will be corrected in the next release
        // i promise
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        require(_invoice.totalPrice != 0);  // check if exists
        require(msg.value >= _invoice.totalPrice);

        _mint(_customer,"Huy ego znaet chto zdes");

        // ti mojet poprobuesh prodavsu chego otpravit? 
    }


    function _mint(address _owner,string _dataHash) internal {
        Token memory _token = Token({
            dataHash: _dataHash
        });

        uint256 _tokenId = allTokens.length;
        // Just to make sure
        require(_tokenId <= 4294967295);
        allTokens.push(_token); 

        addTokenTo(_owner,_tokenId);
    }




    // Dalshe huynya ne listay

    function res(string _hash) public view returns(string) {
        return hashToData[_hash];
    }

    function get(uint i) public view returns(uint256) {
        return parseInt(form[i]);
    }

    function check() public returns(bytes32) {
        return keccak256(strConcat("0xf17f52151ebef6c7334fad080c5704d77216b732","570000000000000000"));
    }


    function() public payable {}
}
