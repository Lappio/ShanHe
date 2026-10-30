<template>
  <div>
    <div class="toolbar">
      <el-select v-model="status" clearable placeholder="状态" style="width:140px" @change="load">
        <el-option label="待出行" value="PENDING" /><el-option label="已完成" value="COMPLETED" /><el-option label="已取消" value="CANCELLED" />
      </el-select>
      <el-input v-model="keyword" placeholder="订单号 / 联系人" style="width:220px" clearable @keyup.enter="load" />
      <el-button @click="load">查询</el-button>
    </div>
    <el-table :data="rows" border>
      <el-table-column prop="orderNo" label="订单号" width="140" />
      <el-table-column prop="username" label="用户" width="100" />
      <el-table-column prop="spotName" label="景点" />
      <el-table-column prop="ticketName" label="票种" width="110" />
      <el-table-column prop="visitDate" label="日期" width="120" />
      <el-table-column prop="quantity" label="数量" width="70" />
      <el-table-column prop="totalAmount" label="金额" width="90" />
      <el-table-column label="状态" width="160">
        <template #default="{ row }">
          <el-select v-if="row.status === 'PENDING'" :model-value="row.status" size="small" @change="(value) => change(row, value)">
            <el-option label="待出行" value="PENDING" disabled />
            <el-option label="已完成" value="COMPLETED" /><el-option label="已取消" value="CANCELLED" />
          </el-select>
          <span v-else>{{ orderStatusText(row.status) }}</span>
        </template>
      </el-table-column>
    </el-table>
    <div class="pager"><el-pagination background layout="prev, pager, next" :total="total" :page-size="10" :current-page="page" @current-change="(p)=>{page=p;load()}" /></div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../../api'
import { orderStatusText } from '../../utils/format'
const rows = ref([])
const total = ref(0)
const page = ref(1)
const status = ref('')
const keyword = ref('')
async function load() {
  const data = await api.admin.orders({ status: status.value || undefined, keyword: keyword.value || undefined, page: page.value, size: 10 })
  rows.value = data.records
  total.value = data.total
}
async function change(row, value) { await api.admin.orderStatus(row.id, value); load() }
onMounted(load)
</script>
