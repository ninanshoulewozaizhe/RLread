<template>
  <el-card shadow="hover">
    <img class="bookImg" :src="book.image">
    <div class="bookName">{{book.name}}</div>
    <div class="owner" v-if="owner.length">{{owner}}</div>
  </el-card>
</template>

<script>
export default {
  name: 'bookCard',
  props: {
    book: Object,
    owner: String
  }
}
</script>

<style scoped>
.el-card {
  float: left;
  width: 200px;
  height: 250px;
  margin: 0 50px 20px 0;
}

.el-card__body {
  padding: 0 !important
}

.bookImg {
  width: 160px;
  height: 200px;
  margin: 0 auto;
}
</style>
