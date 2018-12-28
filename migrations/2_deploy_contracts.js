var RlreadStore = artifacts.require('./RlreadStore.sol')
var Bookshelf = artifacts.require('./Bookshelf.sol')

module.exports = function (deployer) {
  deployer.deploy(Bookshelf)
  deployer.link(Bookshelf, RlreadStore)
  deployer.deploy(RlreadStore)
}
