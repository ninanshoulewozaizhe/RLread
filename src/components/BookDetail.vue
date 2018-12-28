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
        <el-form-item label="价格(wei)：">
          <span >{{book.price}}</span>
        </el-form-item>
      </el-form>
    </div>

    <el-card class="desc-card">
      <div slot="header" class="clearfix">
        <span>内容简介</span>
      </div>
      <div>
        {{book.description}}
      </div>
    </el-card>
    <div class="btnContainer">
      <el-button type="primary" @click="read">{{buttonText}}</el-button>
      <el-button type="primary" @click="getNowKeepDays" v-if="own === bookId">坚持天数</el-button>
      <el-button type="primary" @click="getMostKeepDays" v-if="own === bookId">最久坚持天数</el-button>
      <el-button type="primary" @click="getAllDaysSpent" v-if="own === bookId">总天数</el-button>
      <el-button type="primary" @click="getMoney" v-if="own === bookId">阅读结束取钱</el-button>
    </div>
  </div>
</template>

<script>
import BOOKS_SUMMARY from '@/constants/books-summary/booksSummary'

export default {
  name: 'BookDetail',
  mounted: function () {
    this.bookId = parseInt(this.$route.params.bookId)
    this.book = BOOKS_SUMMARY[this.bookId - 1]
    this.own = parseInt(this.$route.query.own)
  },
  data () {
    return {
      bookId: 0,
      book: {},
      own: 0
    }
  },
  computed: {
    buttonText: function () {
      return this.own === this.bookId ? '阅读打卡' : '购买阅读'
    }
  },
  methods: {
    read: async function () {
      if (this.own === this.bookId) {
        let result = await this.$contracts.bookShelf.Reading(this.user.account, {from: this.user.account})
        console.log('reading')
        console.log(result)
      } else if (this.own !== 0) {
        this.$notify({
          title: '警告',
          message: '你已经有了一本书啦，读完有的书再买新的把',
          type: 'warning'
        })
      } else {
        try {
          console.log(this.user)
          let result = await this.$contracts.RlreadStore.BuyTheBook.sendTransaction(this.book.name, {from: this.user.account, value: this.book.price})
          console.log('buying')
          console.log(result)
          this.user.bookId = this.bookId
          this.own = this.bookId
        } catch (err) {
          console.log(err)
        }
      }
    },
    getNowKeepDays: async function () {
      try {
        let result = await this.$contracts.bookShelf.GetTheNowKeepDays.call(this.user.account, {from: this.user.account})
        console.log(result)
      } catch (err) {
        console.log(err)
      }
    },
    getMostKeepDays: async function () {
      try {
        let result = await this.$contracts.bookShelf.GetTheMostKeepDays.call(this.user.account, {from: this.user.account})
        console.log(result)
      } catch (err) {
        console.log(err)
      }
    },
    getAllDaysSpent: async function () {
      try {
        let result = await this.$contracts.bookShelf.GetAlldaysSpent.call(this.user.account, {from: this.user.account})
        console.log(result)
      } catch (err) {
        console.log(err)
      }
    },
    getMoney: async function () {
      try {
        let result = await this.$contracts.RlreadStore.ReaderGetMoney.call(this.book.name, {from: this.user.account})
        console.log(result)
      } catch (err) {
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
}

.bookImg {
  width: 200px;
  height: 250px;
  margin: 0;
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
