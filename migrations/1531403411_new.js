var Market = artifacts.require("./MineorityMarket.sol");
var OwnedProxy = artifacts.require("./OwnedUpgradeabilityProxy.sol");

module.exports = async function(deployer) {
  // Use deployer to state migration tasks.
  await deployer.deploy(Market);
  const marketInstance = await Market.deployed();

  await deployer.deploy(OwnedProxy);
  const marketProxy = await OwnedProxy.deployed();
  await marketProxy.upgradeTo(marketInstance.address)
};
