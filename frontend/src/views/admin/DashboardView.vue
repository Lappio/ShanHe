<template>
  <div v-loading="loading">
    <div class="stat-cards">
      <article><span class="muted">用户</span><strong>{{ stats.userCount }}</strong></article>
      <article><span class="muted">在售景点</span><strong>{{ stats.spotCount }}</strong></article>
      <article><span class="muted">有效订单</span><strong>{{ stats.orderCount }}</strong></article>
      <article><span class="muted">成交额</span><strong>{{ money(stats.revenue) }}</strong></article>
      <article><span class="muted">今日订单</span><strong>{{ stats.todayOrders }}</strong></article>
      <article><span class="muted">已发布游记</span><strong>{{ stats.noteCount }}</strong></article>
      <article><span class="muted">待审游记</span><strong>{{ stats.pendingNotes }}</strong></article>
      <article><router-link to="/admin/notes">去审核</router-link></article>
    </div>
    <div class="chart-grid">
      <div class="chart-box"><div ref="trendRef" class="chart"></div></div>
      <div class="chart-box"><div ref="topRef" class="chart"></div></div>
      <div class="chart-box"><div ref="growthRef" class="chart"></div></div>
      <div class="chart-box"><div ref="catRef" class="chart"></div></div>
    </div>
  </div>
</template>

<script setup>
import { nextTick, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { use, init } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, BarChart, PieChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent, TitleComponent } from 'echarts/components'
import { api } from '../../api'
import { money } from '../../utils/format'

use([CanvasRenderer, LineChart, BarChart, PieChart, GridComponent, TooltipComponent, LegendComponent, TitleComponent])

const loading = ref(false)
const stats = reactive({})
const trendRef = ref()
const topRef = ref()
const growthRef = ref()
const catRef = ref()
const charts = []

function chart(el, option) {
  const instance = init(el)
  instance.setOption(option)
  charts.push(instance)
}

async function load() {
  loading.value = true
  try {
    Object.assign(stats, await api.admin.stats())
    await nextTick()
    chart(trendRef.value, {
      title: { text: '近 14 日订单', left: 8, textStyle: { fontSize: 15 } },
      tooltip: { trigger: 'axis' },
      legend: { data: ['订单数', '金额'] },
      grid: { left: 48, right: 48, bottom: 32, top: 48 },
      xAxis: { type: 'category', data: stats.trendDays.map((day) => day.slice(5)) },
      yAxis: [{ type: 'value', name: '单' }, { type: 'value', name: '元' }],
      series: [
        { name: '订单数', type: 'line', smooth: true, data: stats.trendOrderCounts, itemStyle: { color: '#1e6b58' }, areaStyle: { opacity: 0.12 } },
        { name: '金额', type: 'bar', yAxisIndex: 1, data: stats.trendAmounts, itemStyle: { color: '#b6894a' } },
      ],
    })
    chart(topRef.value, {
      title: { text: '热门景点订单', left: 8, textStyle: { fontSize: 15 } },
      tooltip: { trigger: 'axis' },
      grid: { left: 90, right: 16, bottom: 24, top: 48 },
      xAxis: { type: 'value' },
      yAxis: { type: 'category', data: [...stats.topSpotNames].reverse() },
      series: [{ type: 'bar', data: [...stats.topSpotCounts].reverse(), itemStyle: { color: '#b8432f' } }],
    })
    chart(growthRef.value, {
      title: { text: '近 14 日新增用户', left: 8, textStyle: { fontSize: 15 } },
      tooltip: { trigger: 'axis' },
      grid: { left: 40, right: 16, bottom: 32, top: 48 },
      xAxis: { type: 'category', data: stats.growthDays.map((day) => day.slice(5)) },
      yAxis: { type: 'value', minInterval: 1 },
      series: [{ type: 'line', smooth: true, data: stats.growthCounts, itemStyle: { color: '#2a6278' }, areaStyle: { opacity: 0.15 } }],
    })
    chart(catRef.value, {
      title: { text: '景点分类', left: 8, textStyle: { fontSize: 15 } },
      tooltip: { trigger: 'item' },
      series: [{
        type: 'pie',
        radius: ['38%', '68%'],
        data: stats.categoryNames.map((name, index) => ({ name, value: stats.categoryCounts[index] })),
      }],
    })
  } finally {
    loading.value = false
  }
}

function resize() { charts.forEach((item) => item.resize()) }
onMounted(() => {
  load()
  window.addEventListener('resize', resize)
})
onBeforeUnmount(() => {
  window.removeEventListener('resize', resize)
  charts.forEach((item) => item.dispose())
})
</script>
