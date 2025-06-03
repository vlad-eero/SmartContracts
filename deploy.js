// deploy.js - Script to deploy all contracts
const { ethers } = require("ethers");
const fs = require("fs");

async function main() {
  // Setup provider and wallet
  const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
  const privateKey = process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
  const wallet = new ethers.Wallet(privateKey, provider);
  console.log(`Deploying contracts from ${wallet.address}`);

  // Load contract artifacts
  const AssetToken = JSON.parse(fs.readFileSync("./out/AssetToken.sol/AssetToken.json"));
  const AssetTokenPolicy = JSON.parse(fs.readFileSync("./out/AssetTokenPolicy.sol/AssetTokenPolicy.json"));
  const ProfitDistributor = JSON.parse(fs.readFileSync("./out/ProfitDistributor.sol/ProfitDistributor.json"));
  const ERC1967Proxy = JSON.parse(fs.readFileSync("./out/ERC1967Proxy.sol/ERC1967Proxy.json"));

  // Deploy AssetToken implementation
  console.log("Deploying AssetToken implementation...");
  const AssetTokenFactory = new ethers.ContractFactory(AssetToken.abi, AssetToken.bytecode, wallet);
  const assetTokenImpl = await AssetTokenFactory.deploy();
  await assetTokenImpl.deployed();
  console.log(`AssetToken implementation deployed at: ${assetTokenImpl.address}`);

  // Deploy AssetToken proxy
  console.log("Deploying AssetToken proxy...");
  const initData = AssetTokenFactory.interface.encodeFunctionData("initialize", ["MyToken", "MTK", wallet.address]);
  const ERC1967ProxyFactory = new ethers.ContractFactory(ERC1967Proxy.abi, ERC1967Proxy.bytecode, wallet);
  const assetTokenProxy = await ERC1967ProxyFactory.deploy(assetTokenImpl.address, initData);
  await assetTokenProxy.deployed();
  console.log(`AssetToken proxy deployed at: ${assetTokenProxy.address}`);

  // Deploy AssetTokenPolicy
  console.log("Deploying AssetTokenPolicy...");
  const AssetTokenPolicyFactory = new ethers.ContractFactory(AssetTokenPolicy.abi, AssetTokenPolicy.bytecode, wallet);
  const policy = await AssetTokenPolicyFactory.deploy();
  await policy.deployed();
  console.log(`AssetTokenPolicy deployed at: ${policy.address}`);

  // Deploy ProfitDistributor implementation
  console.log("Deploying ProfitDistributor implementation...");
  const ProfitDistributorFactory = new ethers.ContractFactory(ProfitDistributor.abi, ProfitDistributor.bytecode, wallet);
  const profitDistributorImpl = await ProfitDistributorFactory.deploy();
  await profitDistributorImpl.deployed();
  console.log(`ProfitDistributor implementation deployed at: ${profitDistributorImpl.address}`);

  // Deploy ProfitDistributor proxy
  console.log("Deploying ProfitDistributor proxy...");
  const usdcAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"; // Mock USDC address
  const profitDistInitData = ProfitDistributorFactory.interface.encodeFunctionData("initialize", [
    assetTokenProxy.address,
    usdcAddress,
    wallet.address,
    wallet.address
  ]);
  const profitDistributorProxy = await ERC1967ProxyFactory.deploy(profitDistributorImpl.address, profitDistInitData);
  await profitDistributorProxy.deployed();
  console.log(`ProfitDistributor proxy deployed at: ${profitDistributorProxy.address}`);

  // Set policy and profit distributor in AssetToken
  console.log("Setting policy and profit distributor in AssetToken...");
  const assetToken = new ethers.Contract(assetTokenProxy.address, AssetToken.abi, wallet);
  await assetToken.setPolicy(policy.address);
  await assetToken.setProfitDistributor(profitDistributorProxy.address);
  console.log("Policy and profit distributor set successfully");

  // Save contract addresses to file
  const addresses = {
    assetTokenImpl: assetTokenImpl.address,
    assetTokenProxy: assetTokenProxy.address,
    policy: policy.address,
    profitDistributorImpl: profitDistributorImpl.address,
    profitDistributorProxy: profitDistributorProxy.address,
    usdcAddress: usdcAddress
  };

  fs.writeFileSync("./contract-addresses.json", JSON.stringify(addresses, null, 2));
  console.log("Contract addresses saved to contract-addresses.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });