const Coinflip = artifacts.require("Coinflip");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Coinflip, {from: accounts[0], value: web3.utils.toWei("1", "ether")}); //Send 10 ETH to the contract as initial balance. You can send funds to contract when you are deploying.
};
// THIS IS BROKEN FOR SOME REASON!!
