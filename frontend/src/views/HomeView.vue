<template>
  <div v-loading="loading">
    <el-carousel v-if="banners.length" :height="heroHeight" arrow="hover" indicator-position="outside">
      <el-carousel-item v-for="item in banners" :key="item.id">
        <button class="hero" type="button" :style="{ backgroundImage: `url(${item.imageUrl})` }" @click="openBanner(item)">
          <div class="wrap hero-copy">
            <p class="kicker">中国 · 热门景区</p>
            <h1 class="serif">{{ item.title }}</h1>
            <p>{{ item.subtitle }}</p>
            <span class="btn-gold">去看看</span>
          </div>
        </button>
      </el-carousel-item>
    </el-carousel>
    <div v-else-if="error" class="wrap page">
      <el-empty description="首页暂时没有加载出来">
        <el-button type="primary" @click="load">重试</el-button>
      </el-empty>
    </div>

    <div class="wrap">
      <div class="stat-strip">
        <article><strong>{{ spotTotal }}</strong><span>在册景点</span></article>
        <article><strong>{{ provinces }}</strong><span>覆盖省级行政区</span></article>
        <article><strong>{{ categories.length }}</strong><span>主题分类</span></article>
        <article><strong>{{ routeTotal }}</strong><span>精选路线</span></article>
      </div>

      <section class="section">
        <div class="section-head">
          <div><h2 class="serif">按主题找</h2><p>从历史古迹走到海滨，分类来自后台。</p></div>
        </div>
        <div class="cat-row">
          <button v-for="item in categories" :key="item.id" class="cat-chip" @click="$router.push({ path: '/spots', query: { categoryId: item.id } })">
            <em>{{ item.icon || '景' }}</em>{{ item.name }}
          </button>
        </div>
      </section>

      <section class="section">
        <div class="section-head">
          <div><h2 class="serif">当季热门</h2><p>按访问热度排序，点进去就能看票和开放时间。</p></div>
          <router-link class="more" to="/spots">全部景点</router-link>
        </div>
        <div class="spot-grid">
          <SpotCard v-for="spot in hotSpots" :key="spot.id" :spot="spot" />
        </div>
      </section>

      <section class="section">
        <div class="section-head">
          <div><h2 class="serif">推荐路线</h2><p>多日行程把几个景点按天数串起来。</p></div>
          <router-link class="more" to="/routes">全部路线</router-link>
        </div>
        <div class="route-grid">
          <router-link v-for="item in routes" :key="item.id" :to="`/routes/${item.id}`" class="route-card">
            <div class="cover">
              <img :src="item.coverUrl" :alt="item.title" loading="lazy" />
              <span class="day-flag">{{ item.days }} 天</span>
            </div>
            <div class="body">
              <h3>{{ item.title }}</h3>
              <p class="clamp">{{ item.summary }}</p>
              <div class="meta"><span>参考 {{ priceText(item.priceFrom) }} 起</span><span>不含门票</span></div>
            </div>
          </router-link>
        </div>
      </section>

      <section class="section home-split">
        <div>
          <div class="section-head">
            <h2 class="serif">最新资讯</h2>
            <router-link class="more" to="/news">更多</router-link>
          </div>
          <router-link v-for="item in news" :key="item.id" :to="`/news/${item.id}`" class="news-card">
            <img :src="item.coverUrl" :alt="item.title" loading="lazy" />
            <div>
              <time>{{ item.publishedAt }}</time>
              <h3>{{ item.title }}</h3>
              <p class="clamp">{{ item.summary }}</p>
            </div>
          </router-link>
        </div>
        <div>
          <div class="section-head">
            <h2 class="serif">游记</h2>
            <router-link class="more" to="/notes">全部</router-link>
          </div>
          <router-link v-for="item in notes" :key="item.id" :to="`/notes/${item.id}`" class="note-card" style="display:block;margin-bottom:12px">
            <div class="body">
              <h3>{{ item.title }}</h3>
              <p class="clamp">{{ item.excerpt }}</p>
              <div class="meta"><span>{{ item.authorName }}</span><span>{{ item.likeCount }} 赞</span></div>
            </div>
          </router-link>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '../api'
import { priceText } from '../utils/format'
import SpotCard from '../components/SpotCard.vue'

const router = useRouter()
const loading = ref(false)
const error = ref(false)
const banners = ref([])
const categories = ref([])
const hotSpots = ref([])
const routes = ref([])
const news = ref([])
const notes = ref([])
const spotTotal = ref(0)
const routeTotal = ref(0)
const provinces = ref(0)
const heroHeight = ref(window.innerWidth < 800 ? '380px' : '520px')

function openBanner(item) {
  if (!item.linkUrl) return
  if (item.linkUrl.startsWith('/')) router.push(item.linkUrl)
  else window.open(item.linkUrl, '_blank', 'noopener')
}

async function load() {
  loading.value = true
  error.value = false
  try {
    const [home, provinceList, spotPage, routePage] = await Promise.all([
      api.home(),
      api.provinces(),
      api.spots({ page: 1, size: 1 }),
      api.routes({ page: 1, size: 1 }),
    ])
    banners.value = home.banners || []
    categories.value = home.categories || []
    hotSpots.value = home.hotSpots || []
    routes.value = home.routes || []
    news.value = home.news || []
    notes.value = home.notes || []
    provinces.value = provinceList.length
    spotTotal.value = spotPage.total
    routeTotal.value = routePage.total
  } catch {
    error.value = true
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>
