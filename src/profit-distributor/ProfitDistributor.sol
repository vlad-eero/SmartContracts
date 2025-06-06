// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title ProfitDistributor
 * @notice Distributes USDC profit to holders of a share token (AssetToken) proportionally.
 * @dev Upgradable via UUPS proxy. Only the authorized profitDepositor can deposit profit.
 */
contract ProfitDistributor is Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    IERC20 public shares;
    IERC20 public usdc;
    uint256 public totalReceived;
    uint256 public profitPerTokenStored;
    mapping(address => uint256) public userProfitPerTokenPaid;
    mapping(address => uint256) public rewards;
    uint256 private constant PRECISION = 1e18;
    address public profitDepositor;

    /**
     * @notice Emitted when profit is deposited for distribution.
     * @param from The address that deposited the profit.
     * @param amount The amount of USDC deposited.
     */
    event ProfitReceived(address indexed from, uint256 amount);
    /**
     * @notice Emitted when a user claims their share of the profit.
     * @param to The address that claimed the profit.
     * @param amount The amount of USDC claimed.
     */
    event ProfitClaimed(address indexed to, uint256 amount);

    /**
     * @dev Restricts function to only the authorized profit depositor.
     */
    modifier onlyProfitDepositor() {
        require(msg.sender == profitDepositor, "Not authorized to deposit profit");
        _;
    }

    /**
     * @notice Initializes the contract with the share token, USDC token, and authorized profit depositor.
     * @param sharesAddress The address of the share (AssetToken) contract.
     * @param usdcAddress The address of the USDC contract.
     * @param _profitDepositor The address authorized to deposit profit.
     */
    function initialize(address sharesAddress, address usdcAddress, address _profitDepositor, address owner)
        public
        initializer
    {
        require(sharesAddress != address(0), "Shares address cannot be 0");
        require(usdcAddress != address(0), "USDC address cannot be 0");
        require(_profitDepositor != address(0), "Profit depositor cannot be 0");
        require(owner != address(0), "Owner cannot be 0");

        __Ownable_init(owner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        shares = IERC20(sharesAddress);
        usdc = IERC20(usdcAddress);
        profitDepositor = _profitDepositor;
    }

    /**
     * @notice Sets the address authorized to deposit profit.
     * @dev Only callable by the contract owner.
     * @param _depositor The new authorized profit depositor.
     */
    function setProfitDepositor(address _depositor) external onlyOwner {
        profitDepositor = _depositor;
    }


    /*

    The scope of the depositProfit function is to distribute USDC profit to holders of a share token (AssetToken) proportionally. 
    Specifically, it:
        - Receives USDC tokens from an authorized depositor (the profitDepositor address)
        - Calculates how much profit each share token is entitled to by dividing the deposited amount by the total supply of shares
        - Updates the global accounting variable profitPerTokenStored to track accumulated profit per token
        - Updates the total amount of profit received by the contract
        - Emits an event to log the profit deposit
        - This function is a core part of the profit distribution mechanism in the contract, allowing an authorized entity to deposit profits 
            that will later be claimable by shareholders based on their proportional ownership of the share tokens.
        - The function doesn't directly distribute tokens to shareholders - it only updates the accounting system. 
            Users need to call the separate claim() function to actually receive their share of the profits.

    Use

    // Assuming you have the ProfitDistributor contract instance
    ProfitDistributor profitDistributor = ProfitDistributor(profitDistributorAddress);

    // 1. Make sure you're the authorized profit depositor
    // This can be checked with: require(profitDistributor.profitDepositor() == msg.sender);

    // 2. Approve the contract to spend your USDC
    IERC20 usdc = IERC20(profitDistributor.usdc());
    uint256 amountToDeposit = 1000 * 10**6; // 1000 USDC (assuming 6 decimals)
    usdc.approve(address(profitDistributor), amountToDeposit);

    // 3. Call the depositProfit function
    profitDistributor.depositProfit(amountToDeposit);

    */

    /**
     * @notice Deposits USDC profit to be distributed to share holders.
     * @dev Only callable by the authorized profit depositor. Requires prior approval of USDC.
     * @param amount The amount of USDC to deposit.
     */
    function depositProfit(uint256 amount) external nonReentrant onlyProfitDepositor {
        require(amount > 0, "No USDC sent");
        uint256 totalSupply = shares.totalSupply();
        require(totalSupply > 0, "No shares minted");
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        profitPerTokenStored += (amount * PRECISION) / totalSupply;
        totalReceived += amount;
        emit ProfitReceived(msg.sender, amount);
    }

    /**
     * @notice Returns the amount of profit a user can claim.
     * @param account The address to check.
     * @return The amount of USDC claimable by the user.
     */
    function earned(address account) public view returns (uint256) {
        uint256 balance = shares.balanceOf(account);
        uint256 perToken = profitPerTokenStored - userProfitPerTokenPaid[account];
        return rewards[account] + (balance * perToken) / PRECISION;
    }

    /**
     * @notice Claims the caller's share of the distributed profit in USDC.
     */
    function claim() external nonReentrant {
        uint256 amount = earned(msg.sender);
        require(amount > 0, "Nothing to claim");
        rewards[msg.sender] = 0;
        userProfitPerTokenPaid[msg.sender] = profitPerTokenStored;
        require(usdc.transfer(msg.sender, amount), "USDC transfer failed");
        emit ProfitClaimed(msg.sender, amount);
    }

    /**
     * @notice Updates the reward accounting for two users. Should be called on share transfers.
     * @param from The address sending shares.
     * @param to The address receiving shares.
     */
    function updateReward(address from, address to) public {
        if (from != address(0)) {
            rewards[from] = earned(from);
            userProfitPerTokenPaid[from] = profitPerTokenStored;
        }
        if (to != address(0)) {
            rewards[to] = earned(to);
            userProfitPerTokenPaid[to] = profitPerTokenStored;
        }
    }

    /**
     * @dev Required by UUPS upgradability. Only the owner can authorize upgrades.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
