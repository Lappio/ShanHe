<template>
  <div>
    <div class="toolbar">
      <el-select v-model="status" clearable placeholder="状态" style="width:140px" @change="load">
        <el-option label="展示" value="VISIBLE" /><el-option label="隐藏" value="HIDDEN" />
      </el-select>
      <el-input v-model="keyword" placeholder="评论内容" style="width:200px" @keyup.enter="load" />
      <el-button @click="load">查询</el-button>
    </div>
    <el-table :data="rows" border>
      <el-table-column prop="nickname" label="用户" width="100" />
      <el-table-column prop="targetType" label="类型" width="90" />
      <el-table-column prop="content" label="内容" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column label="操作" width="180">
        <template #default="{ row }">
          <el-button link @click="toggle(row)">{{ row.status === 'VISIBLE' ? '隐藏' : '恢复' }}</el-button>
          <el-button link type="danger" @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import { api } from '../../api'
const rows = ref([])
const total = ref(0)
const page = ref(1)
const status = ref('')
const keyword = ref('')
async function load() {
  const data = await api.admin.comments({ status: status.value || undefined, keyword: keyword.value || undefined, page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function toggle(row) { await api.admin.commentStatus(row.id, row.status === 'VISIBLE' ? 'HIDDEN' : 'VISIBLE'); load() }
async function remove(row) { await ElMessageBox.confirm('删除评论？'); await api.admin.deleteComment(row.id); load() }
onMounted(load)
</script>
