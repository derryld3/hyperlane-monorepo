// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./HypERC20.sol";

/**
 * @title Hyperlane ERC20 Token Router for Bridged USDC
 * @dev This contract extends HypERC20 and uses an existing USDC contract as the source of truth
 * for token balances and transfers. All token operations are delegated to the underlying USDC contract.
 */

interface IFiatTokenV2_2 is IERC20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

contract HypERC20_BridgedUSDC is HypERC20 {
    uint8 private constant TOKEN_DECIMALS = 6;
    uint8 private constant TOKEN_SCALE = 1;
    IFiatTokenV2_2 public immutable usdc;

    /**
     * @notice Constructor that sets the USDC token address and initializes the HypERC20 contract
     * @param _usdcAddress The address of the USDC token contract
     * @param _mailbox The address of the mailbox contract for cross-chain messaging
     */
    constructor(
        address _mailbox,
        address _usdcAddress
    ) HypERC20(TOKEN_DECIMALS, TOKEN_SCALE, _mailbox) {
        require(_usdcAddress != address(0), "USDC address cannot be zero");
        usdc = IFiatTokenV2_2(_usdcAddress);
    }
    /**
     * @dev Override _transfer to add custom transfer logic if needed
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        usdc.transferFrom(from, to, amount);
    }

    /**
     * @dev Override _mint to add custom minting logic if needed
     */
    function _mint(address account, uint256 amount) internal virtual override {
        usdc.mint(account, amount);
    }

    /**
     * @dev Override _burn to add custom burning logic if needed
     */
    function _burn(address account, uint256 amount) internal virtual override {
        usdc.burn(account, amount);
    }

    /**
     * @dev Returns the total supply of the token, which is the total supply of the underlying USDC.
     * @return The total supply of the token.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return usdc.totalSupply();
    }

    /**
     * @dev Returns the balance of tokens for a given account.
     * @param account The address of the account to query the balance for
     * @return The number of tokens owned by `account`
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return usdc.balanceOf(account);
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     * @param owner The address of the account owning tokens
     * @param spender The address of the account able to transfer the tokens
     * @return The amount of tokens `spender` is allowed to transfer on behalf of `owner`
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return usdc.allowance(owner, spender);
    }
}
