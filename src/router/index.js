import Vue from 'vue'
import Router from 'vue-router'
import BookList from '@/components/BookList'
import BookDetail from '@/components/BookDetail'
import home from '@/pages/home'
import store from '@/pages/store'
import manage from '@/pages/manage'

Vue.use(Router)

export default new Router({
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
