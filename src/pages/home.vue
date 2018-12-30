<template>
  <div>
    <div class="logoContainer">
      <img id="storelogo" src="../assets/logo.png">
    </div>
      <el-card class="desc-card"> {{storeDescription}} </el-card>
      <el-button type='primary' @click="dialogVisible = true" round>登录并进入书店</el-button>
      <el-dialog
        title="登录"
        :visible.sync="dialogVisible"
        width="500px">
        <div>
          地址：
          <el-input class="input" v-model="userinfo.account" placeholder="请输入地址"></el-input>
        </div>
        <div>
          密码：
          <el-input type="password" class="input" v-model="userinfo.password" placeholder="请输入密码"></el-input>
        </div>
        <span slot="footer" class="dialog-footer">
          <el-button @click="reset">清空</el-button>
          <el-button type="primary" @click="login" v-loading.fullscreen.lock="Loading">确 定</el-button>
        </span>
      </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'home',
  data () {
    return {
      storeDescription: '只要挑选你想要的书\n每天阅读即可获得一段5分钟左右的英文段落\n坚持阅读可以返现，最高全额返送\n省时又方便地提高您的英语阅读水平',
      dialogVisible: false,
      Loading: false,
      userinfo: {
        account: '',
        password: ''
      }
    }
  },
  methods: {
    reset: function () {
      this.userinfo.account = ''
      this.userinfo.password = ''
    },
    login: async function () {
      if (this.userinfo.account === '') {
        this.$notify({
          title: '警告',
          message: '账号不可为空',
          type: 'warning'
        })
        return
      }
      try {
        this.Loading = true
        await this.$web3.personal.unlockAccount(this.userinfo.account, this.userinfo.password, 0)
        this.user.account = this.userinfo.account
        this.user.password = this.userinfo.password
        let result = await this.$contracts.RlreadStore.EnterBookshop({from: this.user.account})
        console.log(result)
        this.Loading = false
        if (this.user.account === this.SELLER.account) {
          this.$router.push('manage')
        } else {
          this.$router.push('store')
        }
      } catch (err) {
        this.Loading = false
        console.log(err)
        this.$notify({
          title: '警告',
          message: '账号或密码错误',
          type: 'warning'
        })
      }
    }
  }
}
</script>

<style scoped>
#storelogo {
  display: inline-block;
  border-radius: 50%;
  width: 200px;
  height: 200px;
  margin: 50px auto;
  background-color: beige
}

.desc-card {
  width: 400px;
  margin: 0 auto;
  margin-bottom: 20px;
  white-space: pre;
  background-color: beige
}

.input {
  width: 400px;
  margin-bottom: 10px;
}

.el-dialog {
  position: relative;
  top: 300px;
}
</style>
