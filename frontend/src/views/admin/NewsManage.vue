<template>
  <div>
    <div class="toolbar"><el-button type="primary" @click="open()">新增资讯</el-button></div>
    <el-table :data="rows" border>
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="publishedAt" label="发布时间" width="180" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '发布' : '草稿' }}</template></el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link @click="open(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
    <el-dialog v-model="dialog" title="资讯" width="680px">
      <el-form :model="form" label-width="70px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="封面"><el-input v-model="form.coverUrl" /></el-form-item>
        <el-form-item label="摘要"><el-input v-model="form.summary" type="textarea" /></el-form-item>
        <el-form-item label="正文"><el-input v-model="form.content" type="textarea" :rows="8" /></el-form-item>
        <el-form-item label="发布"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" :loading="saving" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import { api } from '../../api'
const rows = ref([])
const dialog = ref(false)
const saving = ref(false)
const page = ref(1)
const total = ref(0)
const form = reactive({ id: null, title: '', coverUrl: '', summary: '', content: '', status: 1 })
async function load() {
  const data = await api.admin.news({ page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function open(row) {
  if (!row) {
    Object.assign(form, { id: null, title: '', coverUrl: '', summary: '', content: '', status: 1 })
  } else {
    Object.assign(form, await api.admin.newsDetail(row.id))
  }
  dialog.value = true
}
async function save() {
  if (saving.value) return
  saving.value = true
  try {
    await api.admin.saveNews({ ...form })
    dialog.value = false
    page.value = 1
    await load()
  } finally {
    saving.value = false
  }
}
async function remove(row) { await ElMessageBox.confirm('删除资讯？'); await api.admin.deleteNews(row.id); load() }
onMounted(load)
</script>
