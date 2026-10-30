<template>
  <div class="wrap page" v-loading="loading">
    <el-empty v-if="error" :description="error">
      <el-button type="primary" @click="load">重试</el-button>
    </el-empty>
    <template v-else-if="routeData">
      <div class="detail-grid">
        <div>
          <img :src="routeData.coverUrl" :alt="routeData.title" style="width:100%;border-radius:18px;max-height:380px;object-fit:cover" />
          <section class="prose" style="margin-top:16px">{{ routeData.detail }}</section>
          <section style="margin-top:16px">
            <h2 class="serif">每日安排</h2>
            <div class="timeline">
              <article v-for="stop in stops" :key="stop.id">
                <img :src="stop.coverUrl" :alt="stop.spotName" />
                <div>
                  <strong>第 {{ stop.dayNo }} 天 · {{ stop.spotName }}</strong>
                  <p class="muted">{{ stop.province }} {{ stop.city }} · 门票 {{ priceText(stop.priceFrom) }}</p>
                  <p>{{ stop.stayNote }}</p>
                  <router-link class="more" :to="`/spots/${stop.spotId}`">查看景点</router-link>
                </div>
              </article>
            </div>
          </section>
        </div>
        <aside class="side-card">
          <h2 class="serif">{{ routeData.title }}</h2>
          <p>{{ routeData.days }} 天 · 参考价 {{ priceText(routeData.priceFrom) }}</p>
          <p class="muted">{{ routeData.summary }}</p>
          <button class="btn-line" type="button" @click="fav">{{ favorited ? '已收藏路线' : '收藏路线' }}</button>
        </aside>
      </div>
    </template>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'
import { priceText } from '../../utils/format'

const route = useRoute()
const user = useUserStore()
const loading = ref(false)
const error = ref('')
const routeData = ref(null)
const stops = ref([])
const favorited = ref(false)

async function load() {
  loading.value = true
  error.value = ''
  routeData.value = null
  try {
    const data = await api.route(route.params.id)
    routeData.value = data.route
    stops.value = data.stops || []
    favorited.value = data.favorited
  } catch (err) {
    error.value = err?.message || '路线不存在或已下线'
  } finally {
    loading.value = false
  }
}
async function fav() {
  if (!user.isLogin) {
    ElMessage.info('请先登录')
    return
  }
  const result = await api.toggleFavorite({ targetType: 'ROUTE', targetId: routeData.value.id })
  favorited.value = result.favorited
}
watch(() => route.params.id, () => {
  if (route.params.id) load()
})
onMounted(load)
</script>
