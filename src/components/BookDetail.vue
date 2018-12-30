<template>
  <div>
    <div class="cardContainer">
      <el-card shadow="never">
      <img class="bookImg" :src="book.image">
      </el-card>
      <el-form label-position="left" label-width="80px" :model="book">
        <el-form-item label="书名：">
          <span >{{book.name}}</span>
        </el-form-item>
        <el-form-item label="作者：">
          <span >{{book.author}}</span>
        </el-form-item>
        <el-form-item label="类型：">
          <span >{{book.type}}</span>
        </el-form-item>
        <el-form-item label="价格：">
          <span >{{book.price}} wei</span>
        </el-form-item>
      </el-form>
    </div>

    <el-card class="desc-card">
      <div slot="header" class="clearfix">
        <span>内容简介</span>
      </div>
      <div class="book-desc">
        {{book.description}}
      </div>
    </el-card>
    <el-dialog title="阅读"
      :visible.sync="dialogVisible"
      width="500px">
      <div class="paragraph">
        {{paragraph}}
      </div>
      <span slot="footer" class="dialog-footer">
      </span>
    </el-dialog>
    <div class="btnContainer">
      <el-button type="primary" @click="read" v-loading.fullscreen.lock="Loading">{{buttonText}}</el-button>
      <el-button type="primary" @click="getNowKeepDays" v-if="own === bookId" v-loading.fullscreen.lock="Loading">坚持天数</el-button>
      <el-button type="primary" @click="getMostKeepDays" v-if="own === bookId" v-loading.fullscreen.lock="Loading">最久坚持天数</el-button>
      <el-button type="primary" @click="getAllDaysSpent" v-if="own === bookId" v-loading.fullscreen.lock="Loading">总天数</el-button>
      <el-button type="primary" @click="getMoney" v-if="own === bookId" v-loading.fullscreen.lock="Loading">阅读结束取钱</el-button>
    </div>
  </div>
</template>

<script>
import BOOKS_SUMMARY from '@/constants/books-summary/booksSummary'
import BOOKS_CONTENT from '@/constants/books-content/booksContent'

export default {
  name: 'BookDetail',
  mounted: function () {
    this.initialData()
  },
  data () {
    return {
      bookId: 0,
      book: {},
      own: 0,
      dialogVisible: false,
      Loading: false,
      paragraph: ''
    }
  },
  computed: {
    buttonText: function () {
      return this.own === this.bookId ? '阅读打卡' : '购买阅读'
    }
  },
  watch: {
    '$route': function (to, from) {
      if (to.query.own !== this.own) {
        this.initialData()
      }
    }
  },
  methods: {
    initialData: function () {
      this.bookId = parseInt(this.$route.params.bookId)
      this.book = BOOKS_SUMMARY[this.bookId - 1]
      this.own = parseInt(this.$route.query.own)
      this.paragraph = BOOKS_CONTENT[this.book.name][0]
    },
    read: async function () {
      if (this.own === this.bookId) {
        this.Loading = true
        let result = await this.$contracts.bookShelf.Reading(this.user.account, {from: this.user.account})
        console.log(result)
        let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
        console.log('reading')
        this.paragraph = BOOKS_CONTENT[this.book.name][userinfo[9].toNumber()]
        this.Loading = false
        this.dialogVisible = true
      } else if (this.own !== 0) {
        this.$notify({
          title: '警告',
          message: '你已经有了一本书啦，读完有的书再买新的把',
          type: 'warning'
        })
      } else {
        try {
          console.log(this.user)
          this.Loading = true
          await this.$web3.personal.unlockAccount(this.user.account, this.user.password, 100000)
          let result = await this.$contracts.RlreadStore.BuyTheBook.sendTransaction(this.bookId, {from: this.user.account, value: this.book.price})
          console.log('buying')
          console.log(result)
          let User = await this.$contracts.RlreadStore.Readers(this.user.account)
          console.log(User)
          let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
          console.log(userinfo)
          let readAddrs = await this.$contracts.RlreadStore.reader_addresses
          console.log(readAddrs)
          this.Loading = false
          this.user.bookId = this.bookId
          this.own = this.bookId
          this.$notify({
            title: '成功',
            message: '您已经成功购买了' + this.book.name + '啦',
            type: 'success'
          })
        } catch (err) {
          this.Loading = false
          console.log(err)
        }
      }
    },
    getNowKeepDays: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.bookShelf.GetTheNowKeepDays.call(this.user.account, {from: this.user.account})
        console.log(result)
        let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
        this.Loading = false
        console.log(userinfo)
        this.$alert('您已坚持' + (userinfo[2].toNumber() + 1) + '天啦', '现在坚持天数', {
          confirmButtonText: '确定'
        })
      } catch (err) {
        this.Loading = false
        console.log(err)
      }
    },
    getMostKeepDays: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.bookShelf.GetTheMostKeepDays.call(this.user.account, {from: this.user.account})
        console.log(result)
        console.log(result.toNumber())
        let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
        this.Loading = false
        console.log(userinfo)
        this.$alert('您最多坚持了' + (userinfo[3].toNumber() + 1) + '天哦', '最多坚持天数', {
          confirmButtonText: '确定'
        })
      } catch (err) {
        this.Loading = false
        console.log(err)
      }
    },
    getAllDaysSpent: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.bookShelf.GetAlldaysSpent(this.user.account, {from: this.user.account})
        console.log(result)
        let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
        this.Loading = false
        console.log(userinfo)
        this.$alert('购书至今已过了' + (userinfo[4].toNumber() + 1) + '天啦', '总天数', {
          confirmButtonText: '确定'
        })
      } catch (err) {
        this.Loading = false
        console.log(err)
      }
    },
    getMoney: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.RlreadStore.ReaderGetMoney(this.book.id, {from: this.user.account})
        console.log(result)
        let userinfo = await this.$contracts.bookShelf.Readers(this.user.account)
        this.Loading = false
        console.log(userinfo)
        if (userinfo[4].toNumber() < 80) {
          this.$notify({
            title: '警告',
            message: '还没到期限呢拿不到钱哦',
            type: 'warning'
          })
        } else {
          this.$notify({
            title: '成功',
            message: '您已经拿到' + userinfo[6].toNumber() + 'wei啦',
            type: 'success'
          })
        }
      } catch (err) {
        this.Loading = false
        console.log(err)
      }
    }
  }

}
</script>

<style scoped>
.el-card {
  float: left;
  padding: 0;
  margin: 0;
  background-color: bisque;
}

.bookImg {
  width: 200px;
  height: 250px;
  margin: 0;
}

.paragraph {
  word-wrap: break-word;
  white-space: pre-wrap;
  text-align: left;
}

.book-desc {
  white-space: pre-wrap;
  text-align: left;
}
.el-form {
  float: left;
  margin-left: 20px;
  margin-top: -10px;
}

.el-form-item {
  margin-bottom: 10px;
}

.cardContainer {
  height: 320px;
}

.btnContainer {
  display: flex;
  justify-content: flex-start;
  width: 100%;
}

.desc-card {
  width: 600px;
  margin-bottom: 20px;
}
</style>
