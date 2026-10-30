<template>
  <div>
    <div class="toolbar"><el-button type="primary" @click="open()">新增分类</el-button></div>
    <el-table :data="rows" border>
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="icon" label="印记" width="80" />
      <el-table-column prop="description" label="说明" />
      <el-table-column prop="sortOrder" label="排序" width="80" />
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link type="primary" @click="open(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="dialog" title="分类" width="480px">
      <el-form :model="form" label-width="70px">
        <el-form-item label="名称"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="印记"><el-input v-model="form.icon" maxlength="2" /></el-form-item>
        <el-form-item label="说明"><el-input v-model="form.description" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="form.sortOrder" /></el-form-item>
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
const form = reactive({ id: null, name: '', icon: '', description: '', sortOrder: 0 })
async function load() { rows.value = await api.admin.categories() }
function open(row) {
  Object.assign(form, row || { id: null, name: '', icon: '', description: '', sortOrder: 0 })
  dialog.value = true
}
async function save() {
  if (saving.value) return
  saving.value = true
  try {
    await api.admin.saveCategory({ ...form })
    dialog.value = false
    await load()
  } finally {
    saving.value = false
  }
}
async function remove(row) { await ElMessageBox.confirm('删除该分类？'); await api.admin.deleteCategory(row.id); load() }
onMounted(load)
</script>
