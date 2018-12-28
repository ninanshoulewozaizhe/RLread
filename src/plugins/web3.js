import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import BookShelfArtifact from '../../build/contracts/BookShelf.json'
import RlreadStoreArtifact from '../../build/contracts/RlreadStore.json'
import SEllER from '../global/seller'

export default {
  install: async function (Vue) {
    // Modern dapp browsers...
    var web3Provider = null
    if (window.ethereum) {
      web3Provider = window.ethereum
      try {
        // Request account access
        await window.ethereum.enable()
      } catch (error) {
        // User denied account access...
        // eslint-disable-next-line no-console
        console.error('User denied account access')
      }
    } else if (window.web3) {
      // Legacy dapp browsers...
      web3Provider = window.web3.currentProvider
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      web3Provider = new Web3.providers.HttpProvider('http://localhost:7545')
    }
    let web3 = new Web3(web3Provider)
    Vue.prototype.$web3 = web3

    // 初始化合约对象
    let contracts = {}
    let bookShelf = contract(BookShelfArtifact)
    let RlreadStore = contract(RlreadStoreArtifact)
    bookShelf.setProvider(web3.currentProvider)
    RlreadStore.setProvider(web3.currentProvider)
    try {
      contracts.bookShelf = await bookShelf.at('0xf881449a4d68f45e3d7caea3eb9791b3a037df50')
      contracts.RlreadStore = await RlreadStore.at('0x55a37754df9d8649031d98494686cdc4760cc396')
      let result = await contracts.RlreadStore.SetBookshelf(contracts.bookShelf.address, {from: SEllER.account})
      console.log(result)
    } catch (err) {
      console.log(err)
    }
    Vue.prototype.$contracts = contracts
    console.log(Vue.prototype.$contracts)
  }
}
