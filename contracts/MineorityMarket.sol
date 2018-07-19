pragma solidity ^0.4.24;
import "./utils/oraclizeAPI_0.5.sol";
import "./utils/strings.sol";


contract MineorityMarket is usingOraclize {
    using strings for *;

    string public res;
    string[] public form;

    mapping(bytes32 => bool) validIds;
    mapping(string => string) hashToData;

    event ItReturned();

    constructor() {
    }

    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress());
        res = result;

        emit ItReturned();
    }

    function send() public payable {
        bytes32 queryId = oraclize_query("IPFS", "QmX69x5XDtV1KFFNkmkL5aGwCsBzfgjzv7PXt1izGRyTDr");
        validIds[queryId] = true;
    }

    function parse() public {
        var s = res.toSlice();
        var delim = ".".toSlice();
        form = new string[](s.count(delim) + 1);
        for(uint i = 0; i < form.length; i++) {
            form[i] = s.split(delim).toString();
        }
    }

    function get(uint i) public view returns(string) {
        return form[i];
    }



    // Mint (->) Sell -> RemoveFromSale -> transferToBuyer ! (looks terrible)

    // Basically we'll have a mapping hash => data from ipfs,
    // comparing data with something else

    function executeOrder(address[] vendors, uint256[] prices) public payable {
        // Query IPFS

        // Padazhdat eba

        // ...

        // Parse into 3 parts

        // Verify everything, calculate and send everything to everyone
    }





    function _mint() internal {

        // after payment confirmed
    }







    function() public payable{}
}
