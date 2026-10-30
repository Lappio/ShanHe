<template>
  <div class="wrap page" v-loading="loading">
    <div class="section-head">
      <div><h2 class="serif">推荐路线</h2><p>每条路线按天数串联多个景点，门票仍需单独预约。</p></div>
      <el-input v-model="keyword" placeholder="搜索路线" style="width:220px" clearable @keyup.enter="search" @clear="search" />
    </div>
    <el-empty v-if="!loading && routes.length === 0" description="没有匹配的路线" />
    <div class="route-grid">
      <router-link v-for="item in routes" :key="item.id" :to="`/routes/${item.id}`" class="route-card">
        <div class="cover">
          <img :src="item.coverUrl" :alt="item.title" loading="lazy" />
          <span class="day-flag">{{ item.days }} 天</span>
        </div>
        <div class="body">
          <h3>{{ item.title }}</h3>
          <p class="clamp">{{ item.summary }}</p>
          <div class="meta"><span>{{ priceText(item.priceFrom) }} 起</span><span>查看行程</span></div>
        </div>
      </router-link>
    </div>
    <div class="pager">
      <el-pagination background layout="prev, pager, next" :total="total" :page-size="9" :current-page="page" @current-change="(p) => { page = p; load() }" />
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../../api'
import { priceText } from '../../utils/format'

const loading = ref(false)
const routes = ref([])
const total = ref(0)
const page = ref(1)
const keyword = ref('')

async function load() {
  loading.value = true
  try {
    const data = await api.routes({ keyword: keyword.value || undefined, page: page.value, size: 9 })
    routes.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}
function search() {
  page.value = 1
  load()
}
onMounted(load)
</script>
