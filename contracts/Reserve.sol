// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Reserve is Ownable, Initializable {
    using Counters for Counters.Counter;

    address private _publicKey;
    mapping(address => Counters.Counter) private _nonces;
    mapping(uint256 => bool) private withdrawlRecord;

    event Withdraw(
        address indexed user,
        uint256 indexed amount
    );
    
    function initialize(address publicKey_) public initializer {
        _publicKey = publicKey_;
    }

    function withdraw(
        address assertToken, 
        uint256 amount,
        uint256 taskId, 
        uint256 deadline, 
        bytes memory signature
    ) public {
        require(withdrawlRecord[taskId] == false, "Reserve#withdrawal: err withdrawlRecord");
        require(deadline >= block.timestamp, "Reserve#withdrawal: err deadline");
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    _msgSender(),
                    assertToken,
                    amount,
                    taskId,
                    deadline,
                    _useNonce(_msgSender())
                )
            )
        );
        
        // require(SignatureChecker.isValidSignatureNow(_publicKey, messageHash, signature), "Reserve#withdrawal: err signature");

        uint256 assertBalance = IERC20(assertToken).balanceOf(address(this));
        
        if (assertBalance < amount) {
            amount = assertBalance;
        }

        IERC20(assertToken).transfer(_msgSender(), amount);

        withdrawlRecord[taskId] = true;

        emit Withdraw(_msgSender(), amount);
    }

    function nonces(address user) public view virtual returns (uint256) {
        return _nonces[user].current();
    }

    function _useNonce(address user) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[user];
        current = nonce.current();
        nonce.increment();
    }

    function getPublicKey() public view onlyOwner returns (address){
        return _publicKey;
    }

    function setPublicKey(address newPublicKey) public onlyOwner {
        require(_publicKey != newPublicKey, "BDCReserve#setPublicKey: the publicKey not change");
        require(address(0) != newPublicKey, "BDCReserve#setPublicKey: the new publicKey is zero");
        _publicKey = newPublicKey;
    }

    function getMessageHash(
        address assertToken, 
        uint256 amount,
        uint256 taskId, 
        uint256 deadline
    ) public view returns (bytes32, bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                _msgSender(),
                assertToken,
                amount,
                taskId,
                deadline,
                nonces(_msgSender())
            )
        );
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(
            hash
        );

        return (hash, messageHash);
    }

}
