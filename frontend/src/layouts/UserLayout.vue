<template>
  <div>
    <div class="top-strip">
      <div class="wrap">
        <span>全国热门景点文旅门户 · 课程演示数据</span>
        <span>预约咨询 400-800-2026</span>
      </div>
    </div>
    <header class="site-header">
      <div class="wrap header-row">
        <router-link to="/" class="brand">
          <span class="seal">山</span>
          <span><strong>山河纪</strong><small>SHANHE</small></span>
        </router-link>
        <nav class="nav" :class="{ open: menuOpen }">
          <router-link to="/" @click="menuOpen = false">首页</router-link>
          <router-link to="/spots" @click="menuOpen = false">景点</router-link>
          <router-link to="/routes" @click="menuOpen = false">路线</router-link>
          <router-link to="/notes" @click="menuOpen = false">游记</router-link>
          <router-link to="/news" @click="menuOpen = false">资讯</router-link>
          <form class="search nav-search" @submit.prevent="search">
            <input v-model="keyword" placeholder="搜索景点或城市" aria-label="搜索景点" />
            <button type="submit">搜索</button>
          </form>
        </nav>
        <form class="search header-search" @submit.prevent="search">
          <input v-model="keyword" placeholder="搜索景点或城市" aria-label="搜索" />
          <button type="submit">搜索</button>
        </form>
        <div class="account">
          <template v-if="user.isLogin">
            <el-dropdown>
              <span class="ghost">{{ user.profile?.nickname || '游客' }}</span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="$router.push('/user')">个人中心</el-dropdown-item>
                  <el-dropdown-item @click="$router.push('/orders')">我的订单</el-dropdown-item>
                  <el-dropdown-item @click="$router.push('/notes/new')">发布游记</el-dropdown-item>
                  <el-dropdown-item v-if="user.isAdmin" @click="$router.push('/admin')">管理后台</el-dropdown-item>
                  <el-dropdown-item divided @click="logout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <router-link v-else to="/login" class="ghost">登录</router-link>
        </div>
        <button class="menu-btn" type="button" @click="menuOpen = !menuOpen">菜单</button>
      </div>
    </header>
    <router-view />
    <footer class="site-footer">
      <div class="wrap">
        <div class="footer-grid">
          <div>
            <h4 class="serif">山河纪</h4>
            <p>把故宫、西湖、黄山、九寨沟这些名字放回地图上。先看清楚开放时间，再决定哪一天出发。</p>
          </div>
          <div>
            <h4>去看看</h4>
            <ul>
              <li><router-link to="/spots">全部景点</router-link></li>
              <li><router-link to="/routes">推荐路线</router-link></li>
              <li><router-link to="/notes">游记攻略</router-link></li>
            </ul>
          </div>
          <div>
            <h4>说明</h4>
            <p>本站为 Web 编程实践课程设计。票价、库存与开放时间仅供演示，不能作为入园凭证。</p>
            <p><a href="/ATTRIBUTION.md">素材署名</a>：照片来自 Wikimedia Commons，使用 CC0、CC BY 或 CC BY-SA。部分介绍视频是 B 站公开片段的本地副本，仅供课程展示，版权归原作者。</p>
          </div>
        </div>
        <div class="copy">山河纪 · 全国热门景点文旅门户 · 图片与视频地址来自景点数据，署名见 <a href="/ATTRIBUTION.md">素材说明</a></div>
      </div>
    </footer>
    <button v-show="showTop" class="to-top" type="button" @click="toTop">顶</button>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const router = useRouter()
const user = useUserStore()
const keyword = ref('')
const menuOpen = ref(false)
const showTop = ref(false)

function search() {
  menuOpen.value = false
  router.push({ path: '/spots', query: keyword.value ? { keyword: keyword.value } : {} })
}
function logout() {
  user.logout()
  router.push('/')
}
function onScroll() {
  showTop.value = window.scrollY > 480
}
function toTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
onMounted(() => window.addEventListener('scroll', onScroll, { passive: true }))
onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>
