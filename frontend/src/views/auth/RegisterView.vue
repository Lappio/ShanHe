<template>
  <div class="auth-shell">
    <section class="auth-visual" style="background-image:url(/media/images/banner_2.webp)">
      <div>
        <p class="kicker">新旅客</p>
        <h1 class="serif">注册一个只属于这次行程的名字。</h1>
      </div>
    </section>
    <section class="auth-panel">
      <div class="auth-card">
        <h2 class="serif">注册</h2>
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
          <el-form-item label="用户名" prop="username"><el-input v-model="form.username" placeholder="4-20 位字母数字" /></el-form-item>
          <el-form-item label="昵称" prop="nickname"><el-input v-model="form.nickname" /></el-form-item>
          <el-form-item label="手机" prop="phone"><el-input v-model="form.phone" maxlength="11" /></el-form-item>
          <el-form-item label="密码" prop="password"><el-input v-model="form.password" type="password" show-password /></el-form-item>
          <el-button type="primary" style="width:100%" :loading="loading" @click="submit">注册并登录</el-button>
        </el-form>
        <p>已有账号？<router-link to="/login">去登录</router-link></p>
      </div>
    </section>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const user = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', nickname: '', phone: '', password: '' })
const rules = {
  username: [{ required: true, pattern: /^[A-Za-z0-9_]{4,20}$/, message: '4-20 位字母、数字或下划线', trigger: 'blur' }],
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  phone: [{ pattern: /^$|^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }],
  password: [{ required: true, min: 6, message: '密码至少 6 位', trigger: 'blur' }],
}
async function submit() {
  await formRef.value.validate()
  loading.value = true
  try {
    const data = await api.register(form)
    user.setSession(data.token, data.user)
    router.push('/')
  } finally {
    loading.value = false
  }
}
</script>
