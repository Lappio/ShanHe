<template>
  <div>
    <div class="toolbar">
      <el-select v-model="status" clearable placeholder="审核状态" style="width:140px" @change="load">
        <el-option label="待审核" value="PENDING" /><el-option label="已通过" value="APPROVED" /><el-option label="已驳回" value="REJECTED" />
      </el-select>
      <el-input v-model="keyword" placeholder="标题" style="width:200px" @keyup.enter="load" />
      <el-button @click="load">查询</el-button>
    </div>
    <el-table :data="rows" border>
      <el-table-column prop="title" label="标题" min-width="180" />
      <el-table-column prop="authorName" label="作者" width="100" />
      <el-table-column prop="spotName" label="景点" width="120" />
      <el-table-column label="状态" width="90"><template #default="{ row }">{{ noteStatusText(row.status) }}</template></el-table-column>
      <el-table-column label="操作" width="220">
        <template #default="{ row }">
          <el-button link @click="preview(row)">查看</el-button>
          <el-button link type="success" @click="audit(row, 'APPROVED')">通过</el-button>
          <el-button link type="danger" @click="reject(row)">驳回</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
    <el-dialog v-model="dialog" title="游记" width="640px">
      <h3>{{ current?.title }}</h3>
      <p style="white-space:pre-wrap">{{ current?.content }}</p>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import { api } from '../../api'
import { noteStatusText } from '../../utils/format'
const rows = ref([])
const total = ref(0)
const page = ref(1)
const status = ref('PENDING')
const keyword = ref('')
const dialog = ref(false)
const current = ref(null)
async function load() {
  const data = await api.admin.notes({ status: status.value || undefined, keyword: keyword.value || undefined, page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function preview(row) { current.value = await api.note(row.id); dialog.value = true }
async function audit(row, value, reason) { await api.admin.auditNote(row.id, { status: value, rejectReason: reason }); load() }
async function reject(row) {
  const { value } = await ElMessageBox.prompt('请填写驳回原因', '驳回游记')
  await audit(row, 'REJECTED', value)
}
onMounted(load)
</script>
