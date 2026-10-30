<template>
  <div class="auth-shell">
    <section class="auth-visual" style="background-image:url(/media/images/banner_1.webp)">
      <div>
        <p class="kicker">山河纪</p>
        <h1 class="serif">先登录，再把行程定下来。</h1>
        <p>预约、收藏和游记都记在你的账号下。</p>
      </div>
    </section>
    <section class="auth-panel">
      <div class="auth-card">
        <h2 class="serif">登录</h2>
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @submit.prevent="submit">
          <el-form-item label="用户名" prop="username"><el-input v-model="form.username" /></el-form-item>
          <el-form-item label="密码" prop="password"><el-input v-model="form.password" type="password" show-password /></el-form-item>
          <el-button type="primary" style="width:100%" :loading="loading" @click="submit">登录</el-button>
        </el-form>
        <p>没有账号？<router-link to="/register">去注册</router-link></p>
        <div class="account-hint">
          <div>默认账号</div>
          <div>管理员 admin / admin123</div>
          <div>游客 linwan / user123</div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'

const route = useRoute()
const router = useRouter()
const user = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: 'linwan', password: 'user123' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function submit() {
  await formRef.value.validate()
  loading.value = true
  try {
    const data = await api.login(form)
    user.setSession(data.token, data.user)
    router.push(route.query.redirect || (data.user.role === 'ADMIN' ? '/admin' : '/'))
  } finally {
    loading.value = false
  }
}
</script>
