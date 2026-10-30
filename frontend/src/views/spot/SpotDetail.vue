<template>
  <div class="wrap page" v-loading="loading">
    <el-empty v-if="error" description="景点加载失败">
      <el-button type="primary" @click="load">重试</el-button>
    </el-empty>
    <template v-else-if="spot">
      <div class="detail-grid">
        <div>
          <div class="gallery">
            <div class="gallery-main">
              <img :src="current.url || spot.coverUrl" :alt="current.caption || spot.name" />
            </div>
            <div class="thumbs">
              <button v-for="(image, index) in images" :key="image.id" :class="{ active: index === currentIndex }" type="button" @click="currentIndex = index">
                <img :src="image.url" :alt="image.caption || spot.name" loading="lazy" />
              </button>
            </div>
          </div>
          <p v-if="current.caption || current.credit" class="muted">
            {{ current.caption }}
            <template v-if="current.credit">
              ·
              <template v-for="(part, index) in creditParts(current.credit)" :key="index">
                <a v-if="part.href" :href="part.href" target="_blank" rel="noopener">{{ part.label }}</a>
                <span v-else>{{ part.label }}</span>
              </template>
            </template>
          </p>
          <section class="video-block" style="margin-top:16px">
            <h2 class="serif">影像介绍</h2>
            <video v-if="spot.videoUrl && !videoFailed" class="intro-video" controls playsinline preload="metadata" :poster="spot.coverUrl" :src="spot.videoUrl" :key="spot.videoUrl" @error="videoFailed = true"></video>
            <p class="muted" v-if="!spot.videoUrl">暂无介绍视频，可先浏览景点图集。</p>
            <p class="muted" v-else-if="videoFailed">当前浏览器无法播放此格式。<a v-if="videoPage" :href="videoPage" target="_blank" rel="noopener">原始页面</a></p>
            <p class="muted" v-else>
              <template v-for="(part, index) in creditParts(spot.videoCredit)" :key="index">
                <a v-if="part.href" :href="part.href" target="_blank" rel="noopener">{{ part.label }}</a>
                <span v-else>{{ part.label }}</span>
              </template>
              · <a href="/ATTRIBUTION.md">全部署名</a>
            </p>
          </section>
          <section class="prose" style="margin-top:16px">
            <h2 class="serif" style="margin-top:0">{{ spot.name }}</h2>
            {{ spot.detail }}
          </section>
          <section v-if="related.length" class="video-block" style="margin-top:16px">
            <h2 class="serif">同分类的其他景点</h2>
            <div class="spot-grid related-grid">
              <router-link v-for="item in related" :key="item.id" class="spot-card" :to="`/spots/${item.id}`">
                <div class="cover"><img :src="item.coverUrl" :alt="item.name" /></div>
                <div class="body">
                  <h3>{{ item.name }}</h3>
                  <p class="muted">{{ item.province }} · {{ item.city }}</p>
                </div>
              </router-link>
            </div>
          </section>
          <section class="video-block" style="margin-top:16px">
            <h2 class="serif">游客评论</h2>
            <el-empty v-if="comments.length === 0" description="还没有评论" />
            <div v-for="item in comments" :key="item.id" class="comment">
              <img class="avatar" :src="item.avatar" :alt="item.nickname" />
              <div>
                <strong>{{ item.nickname }}</strong>
                <span class="muted"> · {{ item.createdAt }}</span>
                <p>{{ item.content }}</p>
              </div>
            </div>
            <div class="pager" v-if="commentTotal > commentSize">
              <el-pagination background layout="prev, pager, next" :total="commentTotal" :page-size="commentSize" :current-page="commentPage" @current-change="changeCommentPage" />
            </div>
            <el-form v-if="user.isLogin" style="margin-top:12px" @submit.prevent="sendComment">
              <el-input v-model="comment" type="textarea" :rows="3" maxlength="500" show-word-limit placeholder="写下你的参观感受" />
              <el-button type="primary" style="margin-top:8px" :loading="sending" @click="sendComment">发表评论</el-button>
            </el-form>
            <p v-else class="muted">登录后可以评论。<router-link to="/login">去登录</router-link></p>
          </section>
        </div>
        <aside>
          <div class="side-card">
            <p class="kicker" style="color:var(--cinnabar)">{{ spot.categoryName }} · {{ spot.province }} {{ spot.city }}</p>
            <h2 class="serif">{{ spot.name }}</h2>
            <p class="star">{{ spot.rating }} 分 · {{ spot.visitCount }} 次浏览</p>
            <p class="loc"><strong>开放时间</strong><br />{{ spot.openTime || '以景区当日公告为准' }}</p>
            <p class="loc"><strong>地址</strong><br />{{ spot.address }}</p>
            <div class="actions">
              <button class="btn-line" type="button" @click="copyAddress">复制地址</button>
              <a class="btn-line" :href="mapUrl" target="_blank" rel="noopener">地图位置</a>
              <button class="btn-line" type="button" @click="fav">{{ spot.favorited ? '已收藏' : '收藏' }}</button>
            </div>
          </div>
          <div class="side-card" style="margin-top:14px">
            <h2 class="serif">门票</h2>
            <p v-if="tickets.length === 0" class="muted">暂无可预约门票</p>
            <div v-for="ticket in tickets" :key="ticket.id" class="ticket">
              <div>
                <strong>{{ ticket.name }}</strong>
                <p class="muted" style="margin:4px 0 0">{{ ticket.description }}</p>
              </div>
              <strong>{{ priceText(ticket.price) }}</strong>
            </div>
            <router-link v-if="tickets.length" class="btn-pine" :to="`/book/${spot.id}`" style="width:100%;margin-top:8px">预约门票</router-link>
          </div>
        </aside>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'
import { priceText } from '../../utils/format'

const route = useRoute()
const user = useUserStore()
const loading = ref(false)
const error = ref(false)
const spot = ref(null)
const images = ref([])
const tickets = ref([])
const comments = ref([])
const currentIndex = ref(0)
const comment = ref('')
const commentPage = ref(1)
const commentTotal = ref(0)
const commentSize = 10
const sending = ref(false)
const videoFailed = ref(false)
const related = ref([])
const current = computed(() => images.value[currentIndex.value] || {})
const videoPage = computed(() => creditParts(spot.value?.videoCredit).find((part) => part.href)?.href)

function creditParts(text) {
  if (!text) return []
  const match = String(text).match(/https?:\/\/\S+/)
  if (!match) return [{ label: text }]
  const before = text.slice(0, match.index).replace(/[·\s]+$/, '')
  return [{ label: before + ' · ' }, { label: '原始页面', href: match[0] }]
}
const mapUrl = computed(() => {
  if (!spot.value?.longitude) return 'https://www.amap.com'
  return `https://uri.amap.com/marker?position=${spot.value.longitude},${spot.value.latitude}&name=${encodeURIComponent(spot.value.name)}`
})

async function load() {
  loading.value = true
  error.value = false
  try {
    const data = await api.spot(route.params.id)
    spot.value = data.spot
    images.value = data.images?.length ? data.images : [{ id: 0, url: data.spot.coverUrl, caption: data.spot.name }]
    tickets.value = data.tickets || []
    currentIndex.value = 0
    videoFailed.value = false
    comment.value = ''
    commentPage.value = 1
    await loadComments()
    await loadRelated(data.spot)
  } catch {
    error.value = true
  } finally {
    loading.value = false
  }
}

async function loadComments() {
  const page = await api.comments({ targetType: 'SPOT', targetId: route.params.id, page: commentPage.value, size: commentSize })
  comments.value = page.records
  commentTotal.value = page.total
}
function changeCommentPage(page) {
  commentPage.value = page
  loadComments()
}
async function loadRelated(currentSpot) {
  related.value = []
  if (!currentSpot?.categoryId) return
  const page = await api.spots({ categoryId: currentSpot.categoryId, page: 1, size: 8 })
  related.value = (page.records || []).filter((item) => item.id !== currentSpot.id).slice(0, 3)
}

async function copyAddress() {
  try {
    await navigator.clipboard.writeText(spot.value.address)
    ElMessage.success('地址已复制')
  } catch {
    ElMessage.info(spot.value.address)
  }
}

async function fav() {
  if (!user.isLogin) {
    ElMessage.info('请先登录')
    return
  }
  const result = await api.toggleFavorite({ targetType: 'SPOT', targetId: spot.value.id })
  spot.value.favorited = result.favorited
}

async function sendComment() {
  if (!comment.value.trim()) return
  sending.value = true
  try {
    await api.createComment({ targetType: 'SPOT', targetId: spot.value.id, content: comment.value.trim() })
    comment.value = ''
    commentPage.value = 1
    await loadComments()
    ElMessage.success('评论已发布')
  } finally {
    sending.value = false
  }
}

watch(() => route.params.id, () => {
  if (route.params.id) load()
})
onMounted(load)
</script>
