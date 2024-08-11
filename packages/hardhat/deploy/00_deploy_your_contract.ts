import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";
import { parseUnits } from "ethers"; 

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network sepolia`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const tokenDeployment = await deploy("MyToken", {
    from: deployer,
    args: [parseUnits("1000000", 18)], // Supply inicial de 1 millón de tokens con 18 decimales
    log: true,
  });

  const buildSecureContractDeployment = await deploy("BuildSecureContract", {
    from: deployer,
    // Contract constructor arguments
    args: [
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",              // _builderAddress
      "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",              // _buyerAddress (puedes usar otra dirección si es necesario)
      tokenDeployment.address,  // _paymentToken (debe ser la dirección del token ERC20)
      parseUnits("1000", 18),  // _totalAmount (ejemplo de cantidad)
      parseUnits("100", 18),   // _depositAmount (ejemplo de depósito)
      parseUnits("50", 18),    // _penaltyAmount (ejemplo de penalización)
      "0x90F79bf6EB2c4f870365E785982E1f101E93b906",              // _oracleAddress (puedes usar otra dirección si es necesario)
      Math.floor(Date.now() / 1000) + 86400      // _refundDeadline (ejemplo de fecha de vencimiento en segundos)
    ],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const buildSecureContract  = await hre.ethers.getContract<Contract>("BuildSecureContract", deployer);
  console.log("👋 Initial greeting:", buildSecureContract.address);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["BuildSecureContract"];
