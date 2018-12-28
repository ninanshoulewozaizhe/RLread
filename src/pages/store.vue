<template>
  <div>
    <el-container>
    <el-header>
      <div>
        <span>易读英语</span>
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
                <el-menu-item index="1" @click="ToStore">
                  <i class="el-icon-star-off"></i>
                  <span slot="title">查看书籍</span>
                </el-menu-item>
                <el-menu-item index="2" @click="OwnBook">
                  <i class="el-icon-goods"></i>
                  <span slot="title">已购书籍</span>
                </el-menu-item>
              </el-menu>
            </el-aside>
          </el-col>
        </el-row>
        <el-main>
          <router-view></router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>

export default {
  name: 'store',
  mounted: async function () {
    try {
      console.log('getbook')
      console.log(this.user.account)
      let result = await this.$contracts.bookShelf.GetOwnBookName.call(this.user.account, {from: this.SELLER.account})
      console.log(result)
    } catch (err) {
      console.log(err)
    }
  },
  methods: {
    exit: async function () {
      try {
        let result = await this.$contracts.RlreadStore.LeaveBookshop({from: this.user.account})
        console.log(result)
        this.user.account = ''
        this.user.password = ''
        this.$router.push('/')
      } catch (err) {
        console.log(err)
      }
    },
    ToStore: function () {
      this.$router.push('/store')
    },
    OwnBook: function () {
      if (this.user.bookId === 0) {
        this.$notify({
          title: '警告',
          message: '您尚未购买任何书籍',
          type: 'warning'
        })
      } else {
        let id = this.user.bookId.toString()
        let url = '/store/books/' + id + '?own=' + id
        this.$router.push(url)
      }
    }
  }
}
</script>

<style scoped>
.el-aside {
  margin-top: 20px;
  width: 200px !important;
  min-height: 300px;
  border-right: 1px solid #e6e6e6;
}
.el-menu {
  border-right-width: 0;
}

.el-main {
  padding: 20px 0 0 20px;
}

.exit {
  float: right;
}
</style>
