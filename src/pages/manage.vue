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
                <el-menu-item index="/store">
                  <i class="el-icon-star-off"></i>
                  <span slot="title">已售书籍</span>
                </el-menu-item>
              </el-menu>
            </el-aside>
          </el-col>
        </el-row>
        <el-main>

        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
export default {
  name: 'manage',
  methods: {
    exit: async function () {
      try {
        let result = await this.$contracts.RlreadStore.LeaveBookShop({from: this.user.account})
        console.log(result)
        this.user.account = ''
        this.user.password = ''
        this.$router.push('/')
      } catch (err) {
        console.log(err)
      }
    }
  }
}
</script>

<style>
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
