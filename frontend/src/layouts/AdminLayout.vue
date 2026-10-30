<template>
  <div class="admin-shell">
    <aside class="sider">
      <router-link to="/" class="brand">
        <span class="seal">山</span>
        <span><strong>山河纪</strong><small>管理</small></span>
      </router-link>
      <router-link to="/admin/dashboard">数据统计</router-link>
      <router-link to="/admin/spots">景点管理</router-link>
      <router-link to="/admin/categories">分类管理</router-link>
      <router-link to="/admin/tickets">票种管理</router-link>
      <router-link to="/admin/routes">路线管理</router-link>
      <router-link to="/admin/orders">订单管理</router-link>
      <router-link to="/admin/notes">游记审核</router-link>
      <router-link to="/admin/comments">评论管理</router-link>
      <router-link to="/admin/users">用户管理</router-link>
      <router-link to="/admin/banners">轮播管理</router-link>
      <router-link to="/admin/news">资讯管理</router-link>
      <router-link to="/">返回前台</router-link>
    </aside>
    <section class="admin-main">
      <div class="admin-top">
        <strong>{{ title }}</strong>
        <span class="muted">{{ user.profile?.nickname }}</span>
      </div>
      <router-view />
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'

const route = useRoute()
const user = useUserStore()
const title = computed(() => route.meta.title || '管理后台')
</script>
