pragma solidity ^0.4.24;
import "./ERC721.sol";
import "./MineorityBase.sol";

contract MineorityOwnership is MineorityBase, ERC721{

    string public name = "Mineority";
    string public symbol = "MINE";


    //---MODIFIERS---//
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

    //---ERC721 IMPLEMENTATION---//
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165)
            || (_interfaceID == InterfaceSignature_ERC721)
            || (_interfaceID == InterfaceSignature_ERC721Enumerable));
    }

    //* Returns total supply of all current minted tokens
    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    //* Returns current token balance of a given address
    function balanceOf(address _owner) public view returns (uint256 count) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

    //* Returns owner address of a given token
    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        owner = tokenIndexToOwner[_tokenId];
        require(owner != address(0));
    }
    //Consider it useless, test for necessarity
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenIndexToOwner[_tokenId];
        return owner != address(0);
    }

    //* Safe transfer tokens from address to address, includes check if
    // receiving address is an applicable to recieve tokens contract or 
    // a regular address
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) whenNotPaused {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    //* Same as above, but can transfer some bytes of data with tokens
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) whenNotPaused {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    //* Function to transfer token from address to address, with emiting Transfer event
    // Requires the msg sender to be the owner, approved, or operator,
    // and given token to be owned by given address 
    // Usage of this method is discouraged, use `safeTransferFrom` whenever possible
    function transferFrom(address _from,address _to,uint256 _tokenId) public canTransfer(_tokenId) whenNotPaused {
        require(_from != address(0));
        require(_to != address(0));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    //* Function to approve another address to transfer the given token ID 
    // The zero address indicates there is no approved address.
    // There can only be one approved address per token at a given time.
    // Requires the msg sender to be the owner or operator
    function approve(address _to,uint256 _tokenId) public whenNotPaused {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenIndexToApproved[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    //* Function to set or unset operator to a specific address for all
    // its possessions
    // An operator is allowed to transfer all tokens of the sender
    function setApprovalForAll(address _to, bool _approved) public whenNotPaused {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    //* Returns approved address of a given token, or zero
    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenIndexToApproved[_tokenId];
    }

    //* Returns a confirmation if a given address is an operator to owner
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }
    //---ERC721 ENUMERATION IMPLEMENTATION---//

    //* Returns tokenID by index of the tokens list of the given owner
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    //* Return token index by token index
    // Consider it deprecated and just for interface sake
    function tokenByIndex(uint256 _index) public view returns (string) {
        require(_index < totalSupply());
        return (allTokens[_index].dataHash);
    }

    //------//
    //* Internal function to add token to specific address possession
    // Requires token to not be owned by any address 
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenIndexToOwner[_tokenId] == address(0));
        tokenIndexToOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    //* Internal function to remove token from specific address possession
    // Requires address to be token owner
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenIndexToOwner[_tokenId] = address(0);
    }

    //* Internal function to clear current approval of a given token
    // Requires address to be token owner
    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenIndexToApproved[_tokenId] != address(0)) {
            tokenIndexToApproved[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

    //* Internal function to check if address is token owner, operator or approved
    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
    }
}
