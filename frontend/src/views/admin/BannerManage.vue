<template>
  <div>
    <div class="toolbar"><el-button type="primary" @click="open()">新增轮播</el-button></div>
    <el-table :data="rows" border>
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="subtitle" label="副标题" />
      <el-table-column prop="linkUrl" label="链接" />
      <el-table-column prop="sortOrder" label="排序" width="80" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '启用' : '停用' }}</template></el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link @click="open(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="dialog" title="轮播" width="560px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="副标题"><el-input v-model="form.subtitle" /></el-form-item>
        <el-form-item label="图片"><el-input v-model="form.imageUrl" /></el-form-item>
        <el-form-item label="链接"><el-input v-model="form.linkUrl" placeholder="/spots/1" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="form.sortOrder" /></el-form-item>
        <el-form-item label="启用"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
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
const form = reactive({ id: null, title: '', subtitle: '', imageUrl: '', linkUrl: '', sortOrder: 0, status: 1 })
async function load() { rows.value = await api.admin.banners() }
function open(row) { Object.assign(form, row || { id: null, title: '', subtitle: '', imageUrl: '', linkUrl: '', sortOrder: 0, status: 1 }); dialog.value = true }
async function save() {
  if (saving.value) return
  saving.value = true
  try {
    await api.admin.saveBanner({ ...form })
    dialog.value = false
    await load()
  } finally {
    saving.value = false
  }
}
async function remove(row) { await ElMessageBox.confirm('删除轮播？'); await api.admin.deleteBanner(row.id); load() }
onMounted(load)
</script>
