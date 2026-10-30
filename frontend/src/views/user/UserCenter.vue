<template>
  <div class="wrap page">
    <h2 class="serif">个人中心</h2>
    <el-tabs v-model="tab">
      <el-tab-pane label="资料" name="profile">
        <el-form :model="profile" label-width="80px" class="video-block" style="max-width:560px">
          <el-form-item label="头像"><img class="avatar-lg" :src="profile.avatar" alt="" /></el-form-item>
          <el-form-item label="用户名"><el-input :model-value="user.profile?.username" disabled /></el-form-item>
          <el-form-item label="昵称"><el-input v-model="profile.nickname" maxlength="20" /></el-form-item>
          <el-form-item label="手机"><el-input v-model="profile.phone" maxlength="11" /></el-form-item>
          <el-form-item label="邮箱"><el-input v-model="profile.email" /></el-form-item>
          <el-form-item label="头像地址"><el-input v-model="profile.avatar" /></el-form-item>
          <el-button type="primary" :loading="savingProfile" @click="saveProfile">保存资料</el-button>
        </el-form>
        <el-form :model="password" label-width="80px" class="video-block" style="max-width:560px;margin-top:16px">
          <el-form-item label="原密码"><el-input v-model="password.oldPassword" type="password" show-password /></el-form-item>
          <el-form-item label="新密码"><el-input v-model="password.newPassword" type="password" show-password /></el-form-item>
          <el-button :loading="savingPassword" @click="savePassword">修改密码</el-button>
        </el-form>
      </el-tab-pane>
      <el-tab-pane label="收藏" name="fav">
        <el-empty v-if="favorites.length === 0" description="还没有收藏" />
        <div class="note-grid">
          <component v-for="item in favorites" :key="item.id" :is="item.available ? 'router-link' : 'article'" :to="item.available ? targetLink(item) : undefined" class="note-card">
            <img v-if="item.coverUrl" :src="item.coverUrl" :alt="item.title" style="height:140px;width:100%;object-fit:cover" />
            <div class="body">
              <h3>{{ item.title }}</h3>
              <p class="muted">{{ item.subtitle }}</p>
              <el-button v-if="!item.available" size="small" @click="dropFavorite(item)">取消收藏</el-button>
            </div>
          </component>
        </div>
        <div class="pager" v-if="favTotal > pageSize">
          <el-pagination background layout="prev, pager, next" :total="favTotal" :page-size="pageSize" :current-page="favPage" @current-change="(p) => { favPage = p; loadFav() }" />
        </div>
      </el-tab-pane>
      <el-tab-pane label="我的游记" name="notes">
        <el-empty v-if="notes.length === 0" description="还没有游记" />
        <div v-for="item in notes" :key="item.id" class="news-card" style="grid-template-columns: 1fr">
          <div>
            <el-tag size="small">{{ noteStatusText(item.status) }}</el-tag>
            <h3><router-link :to="`/notes/${item.id}`">{{ item.title }}</router-link></h3>
            <p class="muted">{{ item.excerpt }}</p>
            <p v-if="item.rejectReason" class="muted">原因：{{ item.rejectReason }}</p>
          </div>
        </div>
        <div class="pager" v-if="noteTotal > pageSize">
          <el-pagination background layout="prev, pager, next" :total="noteTotal" :page-size="pageSize" :current-page="notePage" @current-change="(p) => { notePage = p; loadNotes() }" />
        </div>
      </el-tab-pane>
      <el-tab-pane label="订单" name="orders">
        <router-link class="btn-pine" to="/orders">打开我的订单</router-link>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'
import { noteStatusText } from '../../utils/format'

const user = useUserStore()
const tab = ref('profile')
const profile = reactive({ nickname: '', phone: '', email: '', avatar: '' })
const password = reactive({ oldPassword: '', newPassword: '' })
const favorites = ref([])
const notes = ref([])
const favPage = ref(1)
const favTotal = ref(0)
const notePage = ref(1)
const noteTotal = ref(0)
const pageSize = 10
const savingProfile = ref(false)
const savingPassword = ref(false)

function targetLink(item) {
  if (item.targetType === 'SPOT') return `/spots/${item.targetId}`
  if (item.targetType === 'ROUTE') return `/routes/${item.targetId}`
  return `/notes/${item.targetId}`
}
async function saveProfile() {
  if (savingProfile.value) return
  savingProfile.value = true
  try {
    const data = await api.updateProfile(profile)
    user.setProfile(data)
    ElMessage.success('资料已更新')
  } finally {
    savingProfile.value = false
  }
}
async function savePassword() {
  if (savingPassword.value) return
  savingPassword.value = true
  try {
    await api.updatePassword(password)
    password.oldPassword = ''
    password.newPassword = ''
    ElMessage.success('密码已修改，请重新登录')
    user.logout()
    location.assign('/login')
  } finally {
    savingPassword.value = false
  }
}
async function loadFav() {
  const fav = await api.myFavorites({ page: favPage.value, size: pageSize })
  favorites.value = fav.records
  favTotal.value = fav.total
}
async function loadNotes() {
  const mine = await api.myNotes({ page: notePage.value, size: pageSize })
  notes.value = mine.records
  noteTotal.value = mine.total
}
async function dropFavorite(item) {
  await api.toggleFavorite({ targetType: item.targetType, targetId: item.targetId })
  await loadFav()
}
onMounted(async () => {
  const me = await api.me()
  user.setProfile(me)
  Object.assign(profile, { nickname: me.nickname, phone: me.phone, email: me.email, avatar: me.avatar })
  await loadFav()
  await loadNotes()
})
</script>
