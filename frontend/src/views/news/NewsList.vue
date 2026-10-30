<template>
  <div class="wrap page" v-loading="loading">
    <div class="section-head"><h2 class="serif">资讯公告</h2></div>
    <router-link v-for="item in list" :key="item.id" :to="`/news/${item.id}`" class="news-card">
      <img :src="item.coverUrl" :alt="item.title" loading="lazy" />
      <div>
        <time>{{ item.publishedAt }}</time>
        <h3>{{ item.title }}</h3>
        <p class="clamp">{{ item.summary }}</p>
      </div>
    </router-link>
    <el-empty v-if="!loading && list.length === 0" description="暂无资讯" />
    <div class="pager">
      <el-pagination background layout="prev, pager, next" :total="total" :page-size="8" :current-page="page" @current-change="(p) => { page = p; load() }" />
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../../api'
const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
async function load() {
  loading.value = true
  try {
    const data = await api.news({ page: page.value, size: 8 })
    list.value = data.records
    total.value = data.total
  } finally { loading.value = false }
}
onMounted(load)
</script>
