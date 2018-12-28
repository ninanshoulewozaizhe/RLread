<template>
  <div>
  <h1>MetaCoin</h1>
  <h2>Example Truffle Dapp</h2>
  <h3>You have <span class="black"><span id="balance"></span> META</span></h3>

  <br>
  <h1>Send MetaCoin</h1>
  <br><label for="amount">Amount:</label><input type="text" id="amount" placeholder="e.g., 95" v-model="amount" />
  <br><label for="receiver">To Address:</label><input type="text" id="receiver" placeholder="e.g., 0x93e66d9baea28c17d9fc393b53e3fbdd76899dae" v-model="receiver" />
  <br><br><button id="send" @click="sendCoin()">Send MetaCoin</button>
  <br><br>
  <span id="status">{{status}}</span>
  <br>
  <span class="hint"><strong>Hint:</strong> open the browser developer console to view any errors and warnings.</span>
  <button @click="start">开始</button>
  </div>
</template>

<script>
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

import metaCoinArtifact from '../../build/contracts/MetaCoin.json'

export default {
  name: 'BlockChain',
  mounted: function () {
    this.MetaCoin = contract(metaCoinArtifact)
    this.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))
  },
  data () {
    return {
      MetaCoin: null,
      web3: null,
      status: 'wait',
      accounts: [],
      account: '',
      value: 0,
      amount: 0,
      receiver: ''
    }
  },
  methods: {
    start: function () {
      const self = this

      // Bootstrap the MetaCoin abstraction for Use.
      this.MetaCoin.setProvider(this.web3.currentProvider)

      // Get the initial account balance so it can be displayed.
      this.web3.eth.getAccounts(function (err, accs) {
        if (err != null) {
          alert('There was an error fetching your accounts.')
          return
        }

        if (accs.length === 0) {
          alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.")
          return
        }

        self.accounts = accs
        self.account = self.accounts[0]
        self.refreshBalance()
      })
    },
    refreshBalance: function () {
      const self = this

      let meta
      this.MetaCoin.deployed().then(function (instance) {
        meta = instance
        return meta.getBalance.call(self.account, { from: self.account })
      }).then(function (value) {
        self.value = value.valueOf()
      }).catch(function (e) {
        console.log(e)
        self.status = 'Error getting balance; see log.'
      })
    },
    sendCoin: function () {
      const self = this

      const amount_ = this.amount
      const receiver_ = this.receiver

      console.log(amount_)
      console.log(receiver_)

      this.status = 'Initiating transaction... (please wait)'

      let meta
      this.MetaCoin.deployed().then(function (instance) {
        meta = instance
        return meta.sendCoin(receiver_, amount_, { from: self.account })
      }).then(function () {
        self.status = 'Transaction complete!'
        self.refreshBalance()
      }).catch(function (e) {
        console.log(e)
        self.status = 'Error sending coin; see log.'
      })
    }
  }
}

</script>

<style>
label {
  display: inline-block;
  width: 100px;
}

input {
  width: 500px;
  padding: 5px;
  font-size: 16px;
}

button {
  font-size: 16px;
  padding: 5px;
}

h1, h2 {
  display: inline-block;
  vertical-align: middle;
  margin-top: 0px;
  margin-bottom: 10px;
}

h2 {
  color: #AAA;
  font-size: 32px;
}

h3 {
  font-weight: normal;
  color: #AAA;
  font-size: 24px;
}

.black {
  color: black;
}

#balance {
  color: black;
}

.hint {
  color: #666;
}
</style>
