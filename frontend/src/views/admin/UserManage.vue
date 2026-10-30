<template>
  <div>
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="用户名 / 昵称" style="width:220px" @keyup.enter="load" />
      <el-button @click="load">查询</el-button>
    </div>
    <el-table :data="rows" border>
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="nickname" label="昵称" />
      <el-table-column prop="phone" label="手机" />
      <el-table-column prop="role" label="角色" width="100" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '正常' : '禁用' }}</template></el-table-column>
      <el-table-column label="操作" width="220">
        <template #default="{ row }">
          <el-button link @click="setRole(row)">{{ row.role === 'ADMIN' ? '降为游客' : '设为管理员' }}</el-button>
          <el-button link @click="setStatus(row)">{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../../api'
const rows = ref([])
const total = ref(0)
const page = ref(1)
const keyword = ref('')
async function load() {
  const data = await api.admin.users({ keyword: keyword.value || undefined, page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function setRole(row) {
  await api.admin.updateUser(row.id, { role: row.role === 'ADMIN' ? 'USER' : 'ADMIN', status: row.status, nickname: row.nickname })
  load()
}
async function setStatus(row) {
  await api.admin.updateUser(row.id, { role: row.role, status: row.status === 1 ? 0 : 1, nickname: row.nickname })
  load()
}
onMounted(load)
</script>
