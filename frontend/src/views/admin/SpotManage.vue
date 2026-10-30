<template>
  <div>
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索景点" style="width:220px" clearable @keyup.enter="load" />
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="openCreate">新增景点</el-button>
    </div>
    <el-table :data="rows" v-loading="loading" border>
      <el-table-column prop="name" label="名称" min-width="140" />
      <el-table-column prop="province" label="省份" width="90" />
      <el-table-column prop="city" label="城市" width="100" />
      <el-table-column prop="categoryName" label="分类" width="110" />
      <el-table-column prop="priceFrom" label="起价" width="80" />
      <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '上架' : '下架' }}</template></el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p) => { page = p; load() }" /></div>

    <el-dialog v-model="dialog" :title="form.id ? '编辑景点' : '新增景点'" width="760px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="名称"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.categoryId" style="width:100%">
            <el-option v-for="item in categories" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="省份"><el-input v-model="form.province" /></el-form-item>
        <el-form-item label="城市"><el-input v-model="form.city" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="form.address" /></el-form-item>
        <el-form-item label="经纬度">
          <el-input v-model="form.longitude" placeholder="经度" style="width:48%" />
          <el-input v-model="form.latitude" placeholder="纬度" style="width:48%;margin-left:4%" />
        </el-form-item>
        <el-form-item label="开放时间"><el-input v-model="form.openTime" /></el-form-item>
        <el-form-item label="简介"><el-input v-model="form.summary" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="详情"><el-input v-model="form.detail" type="textarea" :rows="4" /></el-form-item>
        <el-form-item label="封面"><el-input v-model="form.coverUrl" placeholder="/media/... 或媒体包 URL" /></el-form-item>
        <el-form-item label="视频地址"><el-input v-model="form.videoUrl" placeholder="video_url，留空则前台只显示播放器封面" /></el-form-item>
        <el-form-item label="视频署名"><el-input v-model="form.videoCredit" /></el-form-item>
        <el-form-item label="评分"><el-input-number v-model="form.rating" :min="1" :max="5" :step="0.1" /></el-form-item>
        <el-form-item label="上架"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="图片">
          <div v-for="(image, index) in form.images" :key="index" class="toolbar">
            <el-input v-model="image.url" placeholder="图片 URL" />
            <el-input v-model="image.caption" placeholder="说明" />
            <el-input v-model="image.credit" placeholder="许可署名" />
            <el-button @click="form.images.splice(index, 1)">删除</el-button>
          </div>
          <el-button @click="form.images.push({ url: '', caption: '', credit: '', sortOrder: form.images.length })">添加图片</el-button>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '../../api'

const loading = ref(false)
const saving = ref(false)
const rows = ref([])
const total = ref(0)
const page = ref(1)
const keyword = ref('')
const categories = ref([])
const dialog = ref(false)
const form = reactive(blank())

function num(value) {
  if (value === '' || value === null || value === undefined) return null
  const parsed = Number(value)
  return Number.isNaN(parsed) ? null : parsed
}
function blank() {
  return { id: null, categoryId: null, name: '', province: '', city: '', address: '', longitude: null, latitude: null, openTime: '', summary: '', detail: '', coverUrl: '', videoUrl: '', videoCredit: '', priceFrom: 0, rating: 4.5, status: 1, images: [] }
}
async function load() {
  loading.value = true
  try {
    const data = await api.admin.spots({ keyword: keyword.value || undefined, page: page.value, size: 10 })
    rows.value = data.records
    total.value = data.total
  } finally { loading.value = false }
}
function openCreate() {
  Object.assign(form, blank())
  dialog.value = true
}
async function openEdit(row) {
  const data = await api.admin.spot(row.id)
  Object.assign(form, blank(), data.spot, { images: data.images || [] })
  dialog.value = true
}
async function save() {
  saving.value = true
  try {
    const payload = {
      ...form,
      longitude: num(form.longitude),
      latitude: num(form.latitude),
      images: form.images.filter((item) => item.url && item.url.trim()).map((item, index) => ({ ...item, sortOrder: index })),
    }
    await api.admin.saveSpot(payload)
    ElMessage.success('已保存')
    dialog.value = false
    load()
  } finally { saving.value = false }
}
async function remove(row) {
  await ElMessageBox.confirm(`删除景点「${row.name}」？有订单或路线引用时会被拒绝。`, '删除')
  await api.admin.deleteSpot(row.id)
  load()
}
onMounted(async () => {
  categories.value = await api.categories()
  load()
})
</script>
