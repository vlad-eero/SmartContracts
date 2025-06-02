// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../policy/IAssetTokenPolicy.sol";

/**
 * @title AssetToken
 * @notice ERC20 upgradable token with strict policies for upgrade, mint, and burn. Only the owner can perform these actions.
 */
contract AssetToken is Initializable, ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    address public profitDistributor;
    IAssetTokenPolicy public policy;

    /// @notice Emitted when the profit distributor is updated after a transfer/mint/burn
    event ProfitDistributorRewardUpdated(address indexed from, address indexed to, uint256 amount);
    /// @notice Emitted when new tokens are minted
    event Mint(address indexed to, uint256 amount);
    /// @notice Emitted when tokens are burned
    event Burn(address indexed from, uint256 amount);

    /**
     * @notice Initializes the token with name, symbol, and initial supply.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param owner The owner of the token.
     */
    function initialize(string memory _name, string memory _symbol, address owner) initializer public {
      __ERC20_init(_name, _symbol);
      __Ownable_init(owner);
      __UUPSUpgradeable_init();
    }

    /**
     * @dev Only the owner can authorize contract upgrades.
     */
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @notice Mints new tokens to a specified address. Only the owner can call this.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint (in whole tokens, decimals will be applied).
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(address(policy) == address(0) || policy.canMint(to, amount), "Mint not allowed by policy");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     * @notice Burns tokens from a specified address. Only the owner can call this.
     * @param from The address from which tokens will be burned.
     * @param amount The amount of tokens to burn (in whole tokens, decimals will be applied).
     */
    function burn(address from, uint256 amount) public onlyOwner {
        require(address(policy) == address(0) || policy.canBurn(from, amount), "Burn not allowed by policy");
        _burn(from, amount);
        emit Burn(from, amount);
    }

    /**
     * @notice Sets the address of the ProfitDistributor contract.
     * @dev Only callable by the contract owner.
     * @param _profitDistributor The address of the ProfitDistributor contract.
     */
    function setProfitDistributor(address _profitDistributor) external onlyOwner {
        profitDistributor = _profitDistributor;
    }

    /**
     * @notice Sets the address of the policy contract.
     * @dev Only callable by the contract owner.
     * @param _policy The address of the policy contract.
     */
    function setPolicy(address _policy) external onlyOwner {
        policy = IAssetTokenPolicy(_policy);
    }

    /**
     * @dev Calls updateReward on the ProfitDistributor contract after every transfer, mint, or burn.
     */
    function _update(address from, address to, uint256 amount) internal override {
        if (address(policy) != address(0)) {
            require(policy.canTransfer(from, to, amount), "Transfer not allowed by policy");
        }
        if (profitDistributor != address(0)) {
            (bool success, ) = profitDistributor.call(
                abi.encodeWithSignature("updateReward(address,address)", from, to)
            );
            require(success, "ProfitDistributor update failed");
            emit ProfitDistributorRewardUpdated(from, to, amount);
        }
        super._update(from, to, amount);
        if (address(policy) != address(0)) {
            policy.recordReceived(from, to);
        }
    }
}       