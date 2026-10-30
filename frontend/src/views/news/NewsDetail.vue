<template>
  <div class="wrap page" v-loading="loading">
    <el-empty v-if="error" :description="error">
      <el-button type="primary" @click="load">重试</el-button>
    </el-empty>
    <article v-else-if="news" class="video-block">
      <p class="muted">{{ news.publishedAt }}</p>
      <h2 class="serif" style="margin-top:0">{{ news.title }}</h2>
      <img v-if="news.coverUrl" :src="news.coverUrl" :alt="news.title" style="width:100%;border-radius:12px;max-height:360px;object-fit:cover" />
      <section class="prose" style="box-shadow:none;padding:12px 0">{{ news.content }}</section>
    </article>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { api } from '../../api'
const route = useRoute()
const loading = ref(false)
const error = ref('')
const news = ref(null)
async function load() {
  loading.value = true
  error.value = ''
  news.value = null
  try { news.value = await api.newsDetail(route.params.id) }
  catch (err) { error.value = err?.message || '资讯不存在或加载失败' }
  finally { loading.value = false }
}
watch(() => route.params.id, () => {
  if (route.params.id) load()
})
onMounted(load)
</script>
