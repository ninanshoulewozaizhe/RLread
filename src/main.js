// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import USER from '@/global/user'
import SELLER from '@/global/seller'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import web3Plugin from './plugins/web3'

// 全局引入user变量记录此时登录的用户
Vue.prototype.user = USER
Vue.prototype.SELLER = SELLER
// 全局引入ElementUI、web3对象
Vue.use(ElementUI)
Vue.use(web3Plugin)

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
