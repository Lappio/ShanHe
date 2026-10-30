<template>
  <div class="wrap page" v-loading="loading">
    <el-empty v-if="error" description="游记加载失败">
      <el-button type="primary" @click="load">重试</el-button>
    </el-empty>
    <article v-else-if="note" class="detail-grid">
      <div>
        <img v-if="note.coverUrl" :src="note.coverUrl" :alt="note.title" style="width:100%;border-radius:18px;max-height:420px;object-fit:cover" />
        <p v-if="note.coverUrl" class="muted">封面来自关联景点，作者与许可见 <a href="/ATTRIBUTION.md">素材署名</a>。</p>
        <h2 class="serif">{{ note.title }}</h2>
        <p class="muted">{{ note.authorName }} · {{ note.createdAt }} · {{ note.viewCount }} 次阅读 <span v-if="note.spotName">· {{ note.spotName }}</span></p>
        <el-tag v-if="note.status !== 'APPROVED'" type="warning">{{ noteStatusText(note.status) }}</el-tag>
        <p v-if="note.rejectReason" class="muted">驳回原因：{{ note.rejectReason }}</p>
        <section class="prose">{{ note.content }}</section>
        <div class="actions">
          <button class="btn-pine" type="button" @click="like">{{ note.liked ? '已点赞' : '点赞' }} {{ note.likeCount }}</button>
          <button class="btn-line" type="button" @click="fav">{{ note.favorited ? '已收藏' : '收藏' }}</button>
          <router-link v-if="mine" class="btn-line" :to="`/notes/${note.id}/edit`">编辑</router-link>
        </div>
        <section class="video-block" style="margin-top:16px">
          <h3>评论</h3>
          <div v-for="item in comments" :key="item.id" class="comment">
            <img class="avatar" :src="item.avatar" alt="" />
            <div><strong>{{ item.nickname }}</strong><p>{{ item.content }}</p></div>
          </div>
          <div class="pager" v-if="commentTotal > commentSize">
            <el-pagination background layout="prev, pager, next" :total="commentTotal" :page-size="commentSize" :current-page="commentPage" @current-change="changeCommentPage" />
          </div>
          <el-input v-if="user.isLogin" v-model="comment" type="textarea" :rows="3" maxlength="500" placeholder="说点什么" />
          <el-button v-if="user.isLogin" style="margin-top:8px" type="primary" @click="send">发表</el-button>
          <p v-else class="muted"><router-link to="/login">登录</router-link>后可以评论</p>
        </section>
      </div>
      <aside class="side-card" v-if="note.spotId">
        <h3>相关景点</h3>
        <router-link class="btn-pine" :to="`/spots/${note.spotId}`">去看看 {{ note.spotName }}</router-link>
      </aside>
    </article>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'
import { noteStatusText } from '../../utils/format'

const route = useRoute()
const user = useUserStore()
const loading = ref(false)
const error = ref(false)
const note = ref(null)
const comments = ref([])
const comment = ref('')
const commentPage = ref(1)
const commentTotal = ref(0)
const commentSize = 10
const mine = computed(() => user.profile && note.value && user.profile.id === note.value.userId)

async function load() {
  loading.value = true
  error.value = false
  try {
    comments.value = []
    comment.value = ''
    commentPage.value = 1
    commentTotal.value = 0
    note.value = await api.note(route.params.id)
    if (note.value.status === 'APPROVED') {
      await loadComments()
    }
  } catch {
    error.value = true
    note.value = null
  } finally {
    loading.value = false
  }
}
async function loadComments() {
  const page = await api.comments({ targetType: 'NOTE', targetId: note.value.id, page: commentPage.value, size: commentSize })
  comments.value = page.records
  commentTotal.value = page.total
}
function changeCommentPage(page) {
  commentPage.value = page
  loadComments()
}
async function like() {
  if (!user.isLogin) return ElMessage.info('请先登录')
  const result = await api.likeNote(note.value.id)
  note.value.liked = result.liked
  note.value.likeCount += result.liked ? 1 : -1
}
async function fav() {
  if (!user.isLogin) return ElMessage.info('请先登录')
  const result = await api.toggleFavorite({ targetType: 'NOTE', targetId: note.value.id })
  note.value.favorited = result.favorited
}
async function send() {
  if (!comment.value.trim()) return
  await api.createComment({ targetType: 'NOTE', targetId: note.value.id, content: comment.value.trim() })
  comment.value = ''
  commentPage.value = 1
  await loadComments()
}
watch(() => route.params.id, () => {
  if (route.params.id) load()
})
onMounted(load)
</script>
