pragma solidity ^0.4.24;
import "./MineorityOwnership.sol";
import "./utils/oraclizeAPI_0.5.sol";
import "./utils/strings.sol";


contract MineorityMarket is MineorityOwnership,usingOraclize {
    using strings for *;

    struct Invoice {
        uint256 totalPrice;
        address[] vendors;
        //uint256[] prices;
        // uint256 expirationTime; ???
        // data about purchase ???
    }


    // string[] public form;
    // string[] public form2;
    // string[4][] public form3;
    // Che ze huynya kak bez etogo pizdes
    // string[4] public order;
    bool public suc = false;
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
        OAR = OraclizeAddrResolverI(0x4bfd9Cd9DA9e9D2258796f62fD2B3D3C44dEe479);
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
        bytes32 queryId = oraclize_query("IPFS", _hash, 1200000);
        queryIdToHash[queryId] = _hash;
        validIds[queryId] = true;
    }



    function createInvoiceFromData(string _data) public payable {
        strings.slice memory s = _data.toSlice();
        strings.slice memory delim = ".".toSlice();
        strings.slice memory orders = "/".toSlice();
        strings.slice memory sections = ":".toSlice();
        string[] memory form1 = new string[](s.count(delim) + 1);

        string[] memory form2 = new string[](s.count(orders) + 1);
        
        string[][] memory frm = new string[][](4);
        string[] memory formOrder = new string[](4);

        for(uint i = 0; i < form1.length; i++) {
            form1[i] = s.split(delim).toString();
        }

        strings.slice memory s2 = form1[3].toSlice();

        for(uint j = 0; j < form2.length; j++) {
            form2[j] = s2.split(orders).toString();
            strings.slice memory s3 = form2[j].toSlice();
            for(uint k = 0; k < 4; k++) {
                formOrder[k] = s3.split(sections).toString();
            }
            frm[j] = formOrder; 
        }

        createInv(parseInt(form1[0]),parseAddr(form1[2]),frm);
        suc = true;
    }

    function createInv(uint _price,address _customer,string[][] _invoiceInfo) internal {
        // Take invoice
        address[] memory addr = new address[](_invoiceInfo.length);

        for(uint y = 0; y < _invoiceInfo.length; y++) {
            // It shows second account, need deeper investigation
            addr[y] = parseAddr(_invoiceInfo[0][0]); 
        }
        Invoice memory _invoice = Invoice({
            totalPrice: _price,
            vendors: addr
            //prices: ui
            // expirationTime ???
        });

        userAddressToInvoice[_customer] = _invoice;
    }

    function getInvoice(address _customer) view public returns(uint256,address[]) {
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        return (_invoice.totalPrice,_invoice.vendors);
    }

    function removeInvoice(address _customer) public {
        delete userAddressToInvoice[_customer];
    }

    function executeOrder(address _customer/*,address vendors, uint256 prices*/) public payable {
        // Fuck who's gonna check if he pays for what he ordered
        // will be corrected in the next release
        // i promise
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        require(_invoice.totalPrice != 0);  // check if exists
        require(msg.value >= _invoice.totalPrice);

        _mint(_customer,"Huy ego znaet chto zdes");
        // IPFS hash + good ID
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

    function res(string _hash) public view returns(string) {
        return hashToData[_hash];
    }

    // function get(uint i) public view returns(string) {
    //     return form[i];
    // }
    // function get2(uint i) public view returns(string) {
    //     return form2[i];
    // }
    // function get3(uint i,uint j) public view returns(string) {
    //     return form3[i][j];
    // }


    function() public payable {}
}
