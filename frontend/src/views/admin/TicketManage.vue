<template>
  <div>
    <div class="toolbar">
      <el-select v-model="spotId" clearable filterable placeholder="全部景点" style="width:240px" @change="page = 1; load()">
        <el-option v-for="item in spots" :key="item.id" :label="item.name" :value="item.id" />
      </el-select>
      <el-button type="primary" @click="open()">新增票种</el-button>
    </div>
    <el-table :data="rows" border v-loading="loading">
      <el-table-column prop="spotName" label="景点" />
      <el-table-column prop="name" label="票种" />
      <el-table-column prop="price" label="价格" width="90" />
      <el-table-column prop="dailyStock" label="日库存" width="90" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '在售' : '停售' }}</template></el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link @click="open(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
    <el-dialog v-model="dialog" title="票种" width="520px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="景点">
          <el-select v-model="form.spotId" filterable style="width:100%">
            <el-option v-for="item in spots" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="名称"><el-input v-model="form.name" maxlength="60" show-word-limit /></el-form-item>
        <el-form-item label="价格"><el-input-number v-model="form.price" :min="0" :precision="2" /></el-form-item>
        <el-form-item label="库存"><el-input-number v-model="form.dailyStock" :min="0" /></el-form-item>
        <el-form-item label="说明"><el-input v-model="form.description" type="textarea" /></el-form-item>
        <el-form-item label="在售"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
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
const spots = ref([])
const total = ref(0)
const page = ref(1)
const spotId = ref()
const loading = ref(false)
const saving = ref(false)
const dialog = ref(false)
const form = reactive({ id: null, spotId: null, name: '', price: 0, dailyStock: 1000, description: '', status: 1 })
async function load() {
  loading.value = true
  try {
    const data = await api.admin.tickets({ spotId: spotId.value, page: page.value, size: 10 })
    rows.value = data.records
    total.value = data.total
  } finally { loading.value = false }
}
function open(row) {
  Object.assign(form, row || { id: null, spotId: spotId.value || null, name: '', price: 0, dailyStock: 1000, description: '', status: 1 })
  dialog.value = true
}
async function save() {
  if (saving.value) return
  saving.value = true
  try {
    await api.admin.saveTicket({ ...form })
    dialog.value = false
    page.value = 1
    await load()
  } finally {
    saving.value = false
  }
}
async function remove(row) { await ElMessageBox.confirm('删除该票种？'); await api.admin.deleteTicket(row.id); load() }
onMounted(async () => { spots.value = await api.admin.spotOptions(); load() })
</script>
