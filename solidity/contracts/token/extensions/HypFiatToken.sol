// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {IFiatToken} from "../interfaces/IFiatToken.sol";
import {HypERC20Collateral} from "../HypERC20Collateral.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// see https://github.com/circlefin/stablecoin-evm/blob/master/doc/tokendesign.md#issuing-and-destroying-tokens
contract HypFiatToken is HypERC20Collateral {
    using SafeERC20 for IERC20;

    // Events
    event RouterFeeUpdated(uint32 indexed destination, uint256 fee);
    event FeesCollected(address indexed beneficiary, uint256 amount);
    event RouterFeeStatusChanged(bool isActive);
    event BeneficiaryUpdated(address indexed previous, address indexed current);

    bool public isRouterFeeActive;
    mapping(uint32 => uint256) public routerFees; // destination domain id -> fee amount (raw)
    address public beneficiary;

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only beneficiary can call this function");
        _;
    }

    constructor(
        address _fiatToken,
        uint256 _scale,
        address _mailbox,
        address _beneficiary
    ) HypERC20Collateral(_fiatToken, _scale, _mailbox) {
        require(_beneficiary != address(0), "Beneficiary cannot be zero address");
        beneficiary = _beneficiary;
    }

    function _transferFromSender(
        uint256 _amount
    ) internal override returns (bytes memory metadata) {
        // transfer amount to address(this)
        metadata = super._transferFromSender(_amount);
        // burn amount of address(this) balance
        IFiatToken(address(wrappedToken)).burn(_amount);
    }

    function _transferTo(
        address _recipient,
        uint256 _amount,
        bytes calldata /*metadata*/
    ) internal override {
        require(
            IFiatToken(address(wrappedToken)).mint(_recipient, _amount),
            "FiatToken mint failed"
        );
    }

    function transferRemote(
        uint32 _destination,
        bytes32 _recipient,
        uint256 _amountOrId
    ) external payable override returns (bytes32 messageId) {

        uint256 transferFee = 0;
        uint256 amountAfterFee = _amountOrId;
        
        if (isRouterFeeActive) {
            transferFee = routerFees[_destination];
            require(_amountOrId > transferFee, "Transfer amount must be greater than fee");
            IERC20(address(wrappedToken)).safeTransferFrom(msg.sender, address(this), transferFee);
            // Deduct fee from the amount being transferred
            amountAfterFee = _amountOrId - transferFee;
        }
        
        return _transferRemote(_destination, _recipient, amountAfterFee, msg.value);
    }

    function setRouterFeeActive(bool _isActive) external onlyOwner {
        isRouterFeeActive = _isActive;
        emit RouterFeeStatusChanged(_isActive);
    }

    function setRouterFee(uint32 _destination, uint256 _fee) external onlyOwner {
        routerFees[_destination] = _fee;
        emit RouterFeeUpdated(_destination, _fee);
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary cannot be zero address");
        emit BeneficiaryUpdated(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    function claimCollectedFees() external onlyBeneficiary {
        require(beneficiary != address(0), "Beneficiary not set");
        
        uint256 balance = wrappedToken.balanceOf(address(this));
        require(balance > 0, "No fees to claim");
        
        IERC20(address(wrappedToken)).safeTransfer(beneficiary, balance);
        emit FeesCollected(beneficiary, balance);
    }
}