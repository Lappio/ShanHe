<template>
  <router-link :to="`/spots/${spot.id}`" class="spot-card">
    <div class="cover">
      <img :src="spot.coverUrl" :alt="spot.name" loading="lazy" />
      <span class="badge">{{ spot.province }}</span>
      <span class="price-tag">{{ priceText(spot.priceFrom) }}</span>
    </div>
    <div class="body">
      <h3>{{ spot.name }}</h3>
      <p class="clamp">{{ spot.summary }}</p>
      <div class="meta">
        <span>{{ spot.city }} · {{ spot.categoryName || '景点' }}</span>
        <span class="star">{{ spot.rating }} 分</span>
      </div>
    </div>
  </router-link>
</template>

<script setup>
import { priceText } from '../utils/format'

defineProps({
  spot: { type: Object, required: true },
})
</script>
