<template>
  <div class="wrap page" v-loading="loading">
    <div class="section-head">
      <div><h2 class="serif">游记攻略</h2><p>只展示已通过审核的游记。新稿会先进入待审。</p></div>
      <router-link class="btn-pine" to="/notes/new">写一篇</router-link>
    </div>
    <el-input v-model="keyword" placeholder="搜索标题" style="max-width:320px;margin-bottom:14px" clearable @keyup.enter="search" @clear="search" />
    <el-empty v-if="!loading && notes.length === 0" description="还没有公开游记" />
    <div class="note-grid">
      <router-link v-for="item in notes" :key="item.id" :to="`/notes/${item.id}`" class="note-card">
        <img :src="item.coverUrl" :alt="item.title" style="height:180px;width:100%;object-fit:cover" loading="lazy" />
        <div class="body">
          <h3>{{ item.title }}</h3>
          <p class="clamp">{{ item.excerpt }}</p>
          <div class="meta"><span>{{ item.authorName }} · {{ item.spotName || '自由行' }}</span><span>{{ item.likeCount }} 赞</span></div>
        </div>
      </router-link>
    </div>
    <div class="pager">
      <el-pagination background layout="prev, pager, next" :total="total" :page-size="8" :current-page="page" @current-change="(p) => { page = p; load() }" />
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../../api'

const loading = ref(false)
const notes = ref([])
const total = ref(0)
const page = ref(1)
const keyword = ref('')

async function load() {
  loading.value = true
  try {
    const data = await api.notes({ keyword: keyword.value || undefined, page: page.value, size: 8 })
    notes.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}
function search() { page.value = 1; load() }
onMounted(load)
</script>
