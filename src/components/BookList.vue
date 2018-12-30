<template>
  <div>
    <router-link v-for="book in books" :key="book.id" :to="bookurl(book.id)">
      <book-card :book="book" :owner="''" />
    </router-link>
  </div>
</template>

<script>
import bookCard from '@/components/BookCard'
import BOOKS_SUMMARY from '@/constants/books-summary/booksSummary'

export default {
  name: 'BookList',
  components: {
    'book-card': bookCard
  },
  data () {
    return {
      books: BOOKS_SUMMARY
    }
  },
  methods: {
    bookurl: function (id) {
      return '/store/books/' + id.toString() + '?own=' + this.user.bookId.toString()
    }
  }
}
</script>
