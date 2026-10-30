<template>
  <div class="wrap page" v-loading="loading">
    <div class="section-head">
      <div><h2 class="serif">我的订单</h2><p>待出行订单可以取消，取消后库存会退回。</p></div>
    </div>
    <div class="sort-bar">
      <div class="group">
        <button v-for="item in tabs" :key="item.value" :class="{ active: status === item.value }" type="button" @click="change(item.value)">{{ item.label }}</button>
      </div>
    </div>
    <el-empty v-if="!loading && orders.length === 0" description="还没有订单" />
    <article v-for="item in orders" :key="item.id" class="news-card" style="grid-template-columns: 160px 1fr; margin-bottom: 12px">
      <img :src="item.spotCover" :alt="item.spotName" />
      <div>
        <div class="meta"><span>{{ item.orderNo }}</span><el-tag :type="tagType(item.status)">{{ orderStatusText(item.status) }}</el-tag></div>
        <h3>{{ item.spotName }} · {{ item.ticketName }}</h3>
        <p class="muted">{{ item.visitDate }} · {{ item.quantity }} 张 · {{ money(item.totalAmount) }}</p>
        <p class="muted">联系人 {{ item.contactName }} {{ item.contactPhone }}</p>
        <el-button v-if="item.status === 'PENDING'" size="small" @click="cancel(item)">取消订单</el-button>
      </div>
    </article>
    <div class="pager">
      <el-pagination background layout="prev, pager, next" :total="total" :page-size="8" :current-page="page" @current-change="(p) => { page = p; load() }" />
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import { api } from '../../api'
import { money, orderStatusText } from '../../utils/format'

const loading = ref(false)
const orders = ref([])
const total = ref(0)
const page = ref(1)
const status = ref('')
const tabs = [
  { label: '全部', value: '' },
  { label: '待出行', value: 'PENDING' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' },
]

function tagType(value) {
  if (value === 'PENDING') return 'warning'
  if (value === 'COMPLETED') return 'success'
  return 'info'
}
async function load() {
  loading.value = true
  try {
    const data = await api.myOrders({ status: status.value || undefined, page: page.value, size: 8 })
    orders.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}
function change(value) {
  status.value = value
  page.value = 1
  load()
}
async function cancel(item) {
  await ElMessageBox.confirm(`确定取消订单 ${item.orderNo}？`, '取消预约')
  await api.cancelOrder(item.id)
  load()
}
onMounted(load)
</script>
