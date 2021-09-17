// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721Transfer {
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address internal owner_;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner_ = _owner;
        emit OwnershipTransferred(address(0), owner_);
    }

    modifier onlyOwner() {
        require(owner_ == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return owner_;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC721: new owner is the zero address");
        emit OwnershipTransferred(owner(), _newOwner);
        owner_ = _newOwner;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;


    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract P2PSwapper is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public tradeIdGenerator_;
    uint256 public fee_;
    uint256 public feeBalance_;
    uint256 public feeBalancePending_;

    struct TradeErc20 {
        address token;
        uint256 amount;
    }

    struct TradeErc721 {
        address token;
        uint16[] tokenIds;
    }

    struct TradeEth {
        uint256 proposeEth;
        uint256 requestEth;
    }

    struct Trade {
        address maker;
        address taker;
        TradeErc20[] proposeErc20;
        TradeErc20[] requestErc20;
        uint256 proposeEth;
        uint256 requestEth;
        TradeErc721[] requestErc721;
        TradeErc721[] proposeErc721;
        uint256 expireDt;
        uint256 fee;
    }

    mapping(uint256 => Trade) public trades_;
    mapping(address => uint256[]) public tradeOwners_;
    mapping(uint256 => uint256) public tradeIdIndex_;
    
    string private constant ERR_ETH_AMOUNT_SENT = "wrong ETH amount sent";

    event TradeRegistered(uint256 tradeId, Trade trade);
    event TradeCanceled(uint256 tradeId, Trade trade);
    event TradeAccepted(uint256 tradeId, Trade trade, address indexed taker);
    event WithdrawFee(address indexed receiver, uint256 amount);

    constructor(address _ownerAddr, uint256 _fee) Ownable(_ownerAddr)  {
        fee_ = _fee;
    }
    
    function setFee(uint256 _fee) onlyOwner external {
        fee_ = _fee;
    }
    
    function withdrawFee(address payable _receiver, uint256 _amount) external onlyOwner {
        if (_amount == 0) {
            _amount = feeBalance_;
        }
        
        require(feeBalance_ >= _amount, 'invalid amount');
        
        feeBalance_ -= _amount;

        _receiver.transfer(_amount);

        emit WithdrawFee(_receiver, _amount);
    }
    
    function getTradeIdsByOwner(address _owner) external view returns (uint256[] memory) {
        return tradeOwners_[_owner];
    }

    function createTrade(
        TradeErc20[] calldata _proposeErc20,
        TradeErc20[] calldata _requestErc20,
        TradeErc721[] calldata _proposeErc721,
        TradeErc721[] calldata _requestErc721,
        TradeEth calldata _tradeEth,
        address _takerAddress,
        uint256 _expireDt) payable external nonReentrant() returns (uint256 tradeId) {

        unchecked { tradeIdGenerator_++; }
        
        address msgSender = _msgSender();

        tradeOwners_[msgSender].push(tradeIdGenerator_);
        tradeIdIndex_[tradeIdGenerator_] = tradeOwners_[msgSender].length - 1;

        Trade storage trade = trades_[tradeIdGenerator_];
        trade.maker = msgSender;
        trade.taker = _takerAddress;
        trade.requestEth = _tradeEth.requestEth;
        trade.proposeEth = _tradeEth.proposeEth;
        trade.fee = fee_;

        _fillTradeErc721(trade.proposeErc721, _proposeErc721);
        _fillTradeErc20(trade.proposeErc20, _proposeErc20);

        if (trade.proposeEth > 0) {
            require(msg.value == trade.proposeEth + fee_, ERR_ETH_AMOUNT_SENT);
        } else {
            require(msg.value == fee_, ERR_ETH_AMOUNT_SENT);
        }
        
        if (fee_ > 0) {
            feeBalancePending_ += fee_;
        }

        _fillTradeErc721(trade.requestErc721, _requestErc721);
        _fillTradeErc20(trade.requestErc20, _requestErc20);

        if (_expireDt > 0) {
            require(_expireDt > block.timestamp, 'expire date is already in past');
            trade.expireDt = _expireDt;
        }

        emit TradeRegistered(tradeIdGenerator_, trade);

        return tradeIdGenerator_;
    }

    function cancelTrade(uint256 _tradeId) external nonReentrant() returns (bool) {
        Trade storage trade = trades_[_tradeId];
        require(trade.maker == _msgSender(), "caller is not a trade creator");
        
        uint256 refundEth;

        if (trade.proposeEth > 0) {
            refundEth += trade.proposeEth;
        }
        
        if (trade.fee > 0) {
            refundEth += trade.fee;
            feeBalancePending_ -= trade.fee;
        }
        
        if (refundEth > 0) {
            payable(trade.maker).transfer(refundEth);
        }

        emit TradeCanceled(_tradeId, trade);

        _deleteTrade(trade.maker, _tradeId);

        return true;
    }

    function acceptTrade(uint256 _tradeId) payable external nonReentrant() returns (bool) {
        Trade storage trade = trades_[_tradeId];
        require(trade.maker != address(0x0), 'trade is not registered');
        
        address msgSender = _msgSender();

        if (trade.taker != address(0x0)) {
            require(trade.taker == msgSender, 'caller is not a registered taker');
        }

        if (trade.expireDt != 0) {
            require(trade.expireDt >= block.timestamp, 'trade expired');
        }

        // send to taker
        _transferErc721(trade.proposeErc721, trade.maker, msgSender);
        _transferErc20(trade.proposeErc20, trade.maker, msgSender);

        if (trade.proposeEth > 0) {
            payable(msgSender).transfer(trade.proposeEth);
        }

        // send to maker
        _transferErc721(trade.requestErc721, msgSender, trade.maker);
        _transferErc20(trade.requestErc20, msgSender, trade.maker);

        if (trade.requestEth > 0) {
            require(msg.value == trade.requestEth, ERR_ETH_AMOUNT_SENT);
            payable(trade.maker).transfer(msg.value);
        }

        if (trade.fee > 0) {
            feeBalancePending_ -= trade.fee;
            feeBalance_ += trade.fee;
        }

        emit TradeAccepted(_tradeId, trade, msgSender);

        _deleteTrade(trade.maker, _tradeId);

        return true;
    }
    
    function _fillTradeErc20(TradeErc20[] storage _to, TradeErc20[] calldata _erc20) private {
        if (_erc20.length > 0) {
            for (uint16 i = 0; i < _erc20.length; ++i) {
                require(_erc20[i].amount > 0, 'zero ERC20 amount');
                _to.push(_erc20[i]);
            }
        }
    }

    function _fillTradeErc721(TradeErc721[] storage _to, TradeErc721[] calldata _erc21) private {
        if (_erc21.length > 0) {
            for (uint16 i = 0; i < _erc21.length; ++i) {
                require(_erc21[i].tokenIds.length > 0, "zero tokens of particular ERC721");
                _to.push(_erc21[i]);
            }
        }
    }

    function _transferErc721(TradeErc721[] storage _erc721, address _from, address _to) private {
        if (_erc721.length > 0) {
            for (uint16 i = 0; i < _erc721.length; ++i) {
                for (uint16 k = 0; k < _erc721[i].tokenIds.length; ++k) {
                    IERC721Transfer(_erc721[i].token).safeTransferFrom(_from, _to, _erc721[i].tokenIds[k]);
                }
            }
        }
    }

    function _transferErc20(TradeErc20[] storage _erc20, address _from, address _to) private {
        if (_erc20.length > 0) {
            for (uint16 i = 0; i < _erc20.length; ++i) {
                IERC20(_erc20[i].token).safeTransferFrom(_from, _to, _erc20[i].amount);
            }
        }
    }

    function _deleteTrade(address _owner, uint256 _tradeId) private {
        delete tradeOwners_[_owner][tradeIdIndex_[_tradeId]];
        delete tradeIdIndex_[_tradeId];
        delete trades_[_tradeId];
    }
}