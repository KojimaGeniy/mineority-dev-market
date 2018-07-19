var Market = artifacts.require("./MineorityMarket.sol");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(Market);
};
