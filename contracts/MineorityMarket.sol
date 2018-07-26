pragma solidity ^0.4.24;
import "./MineorityOwnership.sol";
import "./utils/oraclizeAPI_0.5.sol";
import "./utils/strings.sol";


contract MineorityMarket is MineorityOwnership,usingOraclize {
    using strings for *;

    struct Invoice {
        uint256 totalPrice;
        address[] vendors;
        uint256[] prices;
        // uint256 expirationTime; ???
        // descriptions array ???
        // IPFS hash
        // same goes to tokens
    }


    // string[] public form;
    // string[4][] public ordersSectionsStor;
    // string[4] public formOrderStor;
    mapping(bytes32 => bool) validIds;
    mapping(bytes32 => string) queryIdToHash;
    mapping(string => string) hashToData;
    // Or identified by IPFS hash or by queryId or we may add ID's 
    // and map them with users
    // Btw only one invoice allowed per user
    mapping(address => Invoice) userAddressToInvoice;

    event QueryReturned(string _hash);

    constructor() {
        // Just for local testing
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }

    function __callback(bytes32 myid, string result) {
        require(validIds[myid]);
        require(msg.sender == oraclize_cbAddress());
        hashToData[queryIdToHash[myid]] = result;
        delete validIds[myid];
        emit QueryReturned(queryIdToHash[myid]);

        createInvoiceFromData(result);
    }

    function queryIPFS(string _hash) public payable {
        Invoice memory _invoice = userAddressToInvoice[msg.sender]; 
        require(_invoice.totalPrice == 0);
        // 800k is enough for parsing 2 orders
        bytes32 queryId = oraclize_query("IPFS", _hash, 800000);
        queryIdToHash[queryId] = _hash;
        validIds[queryId] = true;
    }



    function createInvoiceFromData(string _data) public payable {
        strings.slice memory _dataS = _data.toSlice();
        strings.slice memory rootSep = ".".toSlice();
        strings.slice memory orderSep = "/".toSlice();
        strings.slice memory sectionsSep = ":".toSlice();
        string[] memory root = new string[](_dataS.count(rootSep) + 1);
        string[] memory orders = new string[](_dataS.count(orderSep) + 1);
        // This number in parentheses initializes first array
        string[][] memory ordersSections = new string[][](_dataS.count(orderSep) + 1);

        for(uint i = 0; i < root.length; i++) {
            root[i] = _dataS.split(rootSep).toString();
        }

        strings.slice memory s2 = root[3].toSlice();

        for(uint j = 0; j < orders.length; j++) {
            // Why it should be initialized every iteration..god only knows,
            // doesn't work otherwise
            string[] memory formOrder = new string[](4);
            orders[j] = s2.split(orderSep).toString();
            strings.slice memory s3 = orders[j].toSlice();
            for(uint k = 0; k < 4; k++) {
                formOrder[k] = s3.split(sectionsSep).toString();
                // formOrderStor[k] = formOrder[k];
            }
            ordersSections[j] = formOrder;
            // ordersSectionsStor.push(formOrderStor); 
            delete formOrder;
        }

        createInv(parseInt(root[0]),parseAddr(root[2]),ordersSections);
    }

    function createInv(uint _price,address _customer,string[][] _invoiceInfo) internal {
        address[] memory addr = new address[](_invoiceInfo.length);
        uint256[] memory ui = new uint256[](_invoiceInfo.length);

        for(uint y = 0; y < _invoiceInfo.length; y++) {
            // It shows second account on both orders, need deeper investigation
            addr[y] = parseAddr(_invoiceInfo[y][0]); 
            ui[y] = parseInt(_invoiceInfo[y][1]);
        }
        Invoice memory _invoice = Invoice({
            totalPrice: _price,
            vendors: addr,
            prices: ui
            // expirationTime ???
        });

        userAddressToInvoice[_customer] = _invoice;
    }

    function getInvoice(address _customer) view public returns(uint256,address[],uint256[]) {
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        return (_invoice.totalPrice,_invoice.vendors,_invoice.prices);
    }

    function removeInvoice(address _customer) public {
        delete userAddressToInvoice[_customer];
    }



    function executeOrder(address _customer) public payable {
        Invoice memory _invoice = userAddressToInvoice[_customer]; 
        require(_invoice.totalPrice != 0);  // check if exists
        require(msg.value >= _invoice.totalPrice);

        for(uint i = 0;i < _invoice.vendors.length; i++) {
            _mint(
                _customer,
                _invoice.vendors[i],
                _invoice.prices[i],
                "IPFS hash here but how to obtain it");

            _invoice.vendors[i].transfer(_invoice.prices[i]);
        }
    }


    function _mint(address _owner,address _vendor,uint256 _price,string _dataHash) internal {
        Token memory _token = Token({
            vendor: _vendor,
            price: _price,
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
    //     return frmStor[i][j];
    // }


    function() public payable {}
}
