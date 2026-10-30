<template>
  <div>
    <div class="toolbar"><el-button type="primary" @click="open()">新增路线</el-button></div>
    <el-table :data="rows" border>
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="days" label="天数" width="80" />
      <el-table-column prop="priceFrom" label="参考价" width="100" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '发布' : '下线' }}</template></el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link @click="open(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
    <el-dialog v-model="dialog" title="路线" width="720px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="天数"><el-input-number v-model="form.days" :min="1" :max="30" /></el-form-item>
        <el-form-item label="参考价"><el-input-number v-model="form.priceFrom" :min="0" /></el-form-item>
        <el-form-item label="封面"><el-input v-model="form.coverUrl" /></el-form-item>
        <el-form-item label="摘要"><el-input v-model="form.summary" type="textarea" /></el-form-item>
        <el-form-item label="正文"><el-input v-model="form.detail" type="textarea" :rows="4" /></el-form-item>
        <el-form-item label="发布"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="站点">
          <div v-for="(stop, index) in form.stops" :key="index" class="toolbar">
            <el-input-number v-model="stop.dayNo" :min="1" :max="form.days" />
            <el-select v-model="stop.spotId" filterable placeholder="景点" style="width:220px">
              <el-option v-for="item in spots" :key="item.id" :label="item.name" :value="item.id" />
            </el-select>
            <el-input v-model="stop.stayNote" placeholder="停留说明" />
            <el-button @click="form.stops.splice(index, 1)">删除</el-button>
          </div>
          <el-button @click="form.stops.push({ dayNo: form.stops.length + 1, spotId: null, sortOrder: form.stops.length + 1, stayNote: '' })">添加景点</el-button>
        </el-form-item>
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
const dialog = ref(false)
const saving = ref(false)
const page = ref(1)
const total = ref(0)
const form = reactive(blank())
function blank() { return { id: null, title: '', days: 1, priceFrom: 0, coverUrl: '', summary: '', detail: '', status: 1, stops: [] } }
async function load() {
  const data = await api.admin.routes({ page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function open(row) {
  Object.assign(form, blank())
  if (row) {
    const data = await api.admin.route(row.id)
    Object.assign(form, data.route, { stops: data.stops || [] })
  }
  dialog.value = true
}
async function save() {
  if (saving.value) return
  saving.value = true
  try {
    await api.admin.saveRoute({ ...form, stops: form.stops.map((stop, index) => ({ ...stop, sortOrder: index + 1 })) })
    dialog.value = false
    page.value = 1
    await load()
  } finally {
    saving.value = false
  }
}
async function remove(row) { await ElMessageBox.confirm('删除路线？'); await api.admin.deleteRoute(row.id); load() }
onMounted(async () => { spots.value = await api.admin.spotOptions(); load() })
</script>
