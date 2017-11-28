var Platform = artifacts.require("Platform.sol")
module.exports = function(deployer) {
  deployer.deploy(Platform);
  //deployer.autolink(); // for linking imports of other contracts
};

var OTC = artifacts.require("OTC.sol")
module.exports = function(deployer) {
  deployer.deploy(OTC);
  //deployer.autolink(); // for linking imports of other contracts
};
