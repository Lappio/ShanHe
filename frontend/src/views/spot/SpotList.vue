<template>
  <div class="wrap page" v-loading="loading">
    <div class="section-head">
      <div>
        <h2 class="serif">景点</h2>
        <p>按分类、省份和票价筛选，关键词会同时匹配名称和城市。</p>
      </div>
      <button class="btn-line" type="button" @click="filtersOpen = !filtersOpen">{{ filtersOpen ? '收起筛选' : '展开筛选' }}</button>
    </div>
    <div class="list-layout">
      <aside v-show="filtersOpen" class="filters">
        <h3>关键词</h3>
        <el-input v-model="keyword" placeholder="故宫 / 杭州" clearable @keyup.enter="apply" @clear="apply" />
        <h3>分类</h3>
        <div class="filter-list">
          <button :class="{ active: !categoryId }" type="button" @click="setCategory(null)">全部</button>
          <button v-for="item in categories" :key="item.id" :class="{ active: categoryId === item.id }" type="button" @click="setCategory(item.id)">{{ item.name }}</button>
        </div>
        <h3>省份</h3>
        <el-select v-model="province" clearable placeholder="全部省份" style="width:100%" @change="apply">
          <el-option v-for="item in provinces" :key="item" :label="item" :value="item" />
        </el-select>
        <h3>票价</h3>
        <div class="filter-list">
          <button v-for="item in priceOptions" :key="item.label" :class="{ active: priceKey === item.label }" type="button" @click="setPrice(item)">{{ item.label }}</button>
        </div>
        <el-button type="primary" style="width:100%;margin-top:12px" @click="apply">应用筛选</el-button>
      </aside>
      <section>
        <div class="sort-bar">
          <span class="muted">共 {{ total }} 处</span>
          <div class="group">
            <button v-for="item in sorts" :key="item.value" :class="{ active: sort === item.value }" type="button" @click="setSort(item.value)">{{ item.label }}</button>
          </div>
        </div>
        <el-empty v-if="!loading && spots.length === 0" description="没有符合条件的景点" />
        <div v-else class="spot-grid" style="grid-template-columns: repeat(auto-fill, minmax(220px, 1fr))">
          <SpotCard v-for="spot in spots" :key="spot.id" :spot="spot" />
        </div>
        <div class="pager">
          <el-pagination background layout="prev, pager, next" :total="total" :page-size="size" :current-page="page" @current-change="changePage" />
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '../../api'
import SpotCard from '../../components/SpotCard.vue'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const spots = ref([])
const total = ref(0)
const categories = ref([])
const provinces = ref([])
const keyword = ref('')
const categoryId = ref(null)
const province = ref('')
const sort = ref('hot')
const page = ref(1)
const size = 9
const priceKey = ref('不限')
const minPrice = ref(undefined)
const maxPrice = ref(undefined)
const filtersOpen = ref(window.innerWidth > 900)
const sorts = [
  { label: '热度', value: 'hot' },
  { label: '最新', value: 'new' },
  { label: '价格升序', value: 'priceAsc' },
  { label: '价格降序', value: 'priceDesc' },
]
const priceOptions = [
  { label: '不限', min: undefined, max: undefined },
  { label: '免费', min: 0, max: 0 },
  { label: '1-50 元', min: 1, max: 50 },
  { label: '51-100 元', min: 51, max: 100 },
  { label: '100 元以上', min: 101, max: undefined },
]

function readQuery() {
  keyword.value = route.query.keyword || ''
  categoryId.value = route.query.categoryId ? Number(route.query.categoryId) : null
  province.value = route.query.province || ''
  sort.value = route.query.sort || 'hot'
  page.value = route.query.page ? Number(route.query.page) : 1
  priceKey.value = route.query.price || '不限'
  const found = priceOptions.find((item) => item.label === priceKey.value) || priceOptions[0]
  minPrice.value = found.min
  maxPrice.value = found.max
}

async function load() {
  loading.value = true
  try {
    const data = await api.spots({
      keyword: keyword.value || undefined,
      categoryId: categoryId.value || undefined,
      province: province.value || undefined,
      sort: sort.value,
      minPrice: minPrice.value,
      maxPrice: maxPrice.value,
      page: page.value,
      size,
    })
    spots.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

function pushQuery() {
  router.replace({
    path: '/spots',
    query: {
      keyword: keyword.value || undefined,
      categoryId: categoryId.value || undefined,
      province: province.value || undefined,
      sort: sort.value,
      price: priceKey.value === '不限' ? undefined : priceKey.value,
      page: page.value > 1 ? page.value : undefined,
    },
  })
}

function apply() {
  page.value = 1
  pushQuery()
}
function setCategory(id) {
  categoryId.value = id
  apply()
}
function setPrice(item) {
  priceKey.value = item.label
  minPrice.value = item.min
  maxPrice.value = item.max
  apply()
}
function setSort(value) {
  sort.value = value
  apply()
}
function changePage(value) {
  page.value = value
  pushQuery()
}

watch(() => route.query, () => { readQuery(); load() })
onMounted(async () => {
  readQuery()
  const [cats, prov] = await Promise.all([api.categories(), api.provinces()])
  categories.value = cats
  provinces.value = prov
  load()
})
</script>
