<template>
  <div>
    <el-container>
    <el-header>
      <div>
        <img src="../assets/title.png" />
        <el-tooltip class="item" effect="dark" content="离开书店" placement="bottom-start">
          <el-button class="exit" icon="el-icon-back" @click="exit" circle></el-button>
        </el-tooltip>
      </div>
    </el-header>
      <el-container>
        <el-row class="tac">
          <el-col :span="12">
            <el-aside class="aside">
              <el-menu
                default-active="1"
                class="el-menu-vertical-demo">
                <el-menu-item index="1">
                  <i class="el-icon-star-off"></i>
                  <span slot="title">已售书籍</span>
                </el-menu-item>
                <el-menu-item index="2" @click="takeMoney" v-loading.fullscreen.lock="Loading">
                  <i class="el-icon-star-off"></i>
                  <span slot="title">收取费用</span>
                </el-menu-item>
              </el-menu>
            </el-aside>
          </el-col>
        </el-row>
        <el-main>
          <div v-for="(book, index) in books" :key="index">
            <book-card :book="book" :owner="''"></book-card>
          </div>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import bookCard from '@/components/BookCard'
import BOOKS_SUMMARY from '@/constants/books-summary/booksSummary'

export default {
  name: 'manage',
  components: {
    'book-card': bookCard
  },
  // mounted: function () {
  // //   let list = await this.$contracts.RlreadStore.getBooksoldCount({from: this.SELLER.account})
  // //   console.log(list)
  //   // const self = this
  //   // this.booklist.forEach(index => {
  //   //   let book = BOOKS_SUMMARY[index - 1]
  //   //   if (self.books.has(book)) {
  //   //     self.books.set(book, self.books.get(book) + 1)
  //   //   } else {
  //   //     self.books.set(book, 1)
  //   //   }
  //   // })
  //   // console.log(this.booklist)
  //   // console.log(this.books)
  // },
  data () {
    return {
      Loading: false,
      booklist: [1, 2, 3, 4, 5, 6, 7, 8]
    }
  },
  computed: {
    books: function () {
      return this.booklist.map(index => BOOKS_SUMMARY[index - 1])
    }
  },
  methods: {
    exit: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.RlreadStore.LeaveBookshop({from: this.user.account})
        this.Loading = false
        console.log(result)
        this.user.account = ''
        this.user.password = ''
        this.$router.push('/')
      } catch (err) {
        this.Loading = false
        console.log(err)
      }
    },
    takeMoney: async function () {
      try {
        this.Loading = true
        let result = await this.$contracts.RlreadStore.SellerGetMoney.sendTransaction({from: this.SELLER.account})
        console.log(result)
        let money = await this.$contracts.RlreadStore.unlockAmount()
        let lockMoney = await this.$contracts.RlreadStore.lockAmount()
        this.Loading = false
        console.log(lockMoney)
        if (money.toNumber() === 0) {
          this.$notify({
            title: '警告',
            message: '暂时没有书籍到期没有可取费用',
            type: 'warning'
          })
        } else {
          this.$notify({
            title: '成功',
            message: '您已收到' + money + 'wei',
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

<style>
.el-header {
  margin-bottom: 20px;
}

.el-aside {
  margin-top: 20px;
  width: 200px !important;
  min-height: 300px;
  border-right: 1px solid #e6e6e6;
}

.el-menu {
  border-right-width: 0;
  background-color: transparent;
}

.el-main {
  padding: 20px 0 0 20px;
}

.exit {
  float: right;
}

</style>
