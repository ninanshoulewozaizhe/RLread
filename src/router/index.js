import Vue from 'vue'
import Router from 'vue-router'
import BookList from '@/components/BookList'
import BookDetail from '@/components/BookDetail'
import home from '@/pages/home'
import store from '@/pages/store'
import manage from '@/pages/manage'
import USER from '@/global/user'
import SELLER from '@/global/seller'

Vue.use(Router)

const router = new Router({
  routes: [
    {
      path: '/',
      component: home
    },
    {
      path: '/store',
      component: store,
      children: [
        {
          path: '',
          component: BookList
        },
        {
          path: 'books/:bookId',
          component: BookDetail,
          props: true
        }
      ]
    },
    {
      path: '/manage',
      component: manage
    }
  ]
})

router.beforeEach((to, from, next) => {
  if (to.path === '/') {
    USER.account = ''
    USER.password = ''
    USER.bookId = 0
    next()
  }
  if (USER.account === '') {
    next('/')
  } else if (to.path === '/manage' && USER.account !== SELLER.account) {
    next(false)
  } else {
    next()
  }
})

export default router
