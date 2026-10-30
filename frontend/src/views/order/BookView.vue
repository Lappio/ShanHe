<template>
  <div class="wrap page" v-loading="loading">
    <el-empty v-if="error" :description="error">
      <el-button type="primary" @click="load">重试</el-button>
    </el-empty>
    <div class="detail-grid" v-else-if="spot">
      <section class="video-block">
        <p class="kicker" style="color:var(--cinnabar)">门票预约</p>
        <h2 class="serif" style="margin-top:0">{{ spot.name }}</h2>
        <p class="muted">{{ spot.province }} · {{ spot.city }} · {{ spot.openTime }}</p>
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" style="margin-top:12px">
          <el-form-item label="游玩日期" prop="visitDate">
            <el-date-picker v-model="form.visitDate" type="date" value-format="YYYY-MM-DD" :disabled-date="disabledDate" placeholder="选择日期" style="width:100%" />
          </el-form-item>
          <el-form-item label="票种" prop="ticketTypeId">
            <p v-if="tickets.length === 0" class="muted">暂无可预约门票</p>
            <label v-for="ticket in tickets" :key="ticket.id" class="ticket" :class="{ active: form.ticketTypeId === ticket.id }">
              <input type="radio" name="ticketType" :value="ticket.id" v-model="form.ticketTypeId" />
              <div>
                <strong>{{ ticket.name }}</strong>
                <p class="muted" style="margin:4px 0 0">{{ ticket.description }}</p>
              </div>
              <strong>{{ priceText(ticket.price) }}</strong>
            </label>
          </el-form-item>
          <el-form-item label="数量" prop="quantity">
            <el-input-number v-model="form.quantity" :min="1" :max="6" />
          </el-form-item>
          <el-form-item label="联系人" prop="contactName">
            <el-input v-model="form.contactName" maxlength="20" />
          </el-form-item>
          <el-form-item label="手机号" prop="contactPhone">
            <el-input v-model="form.contactPhone" maxlength="11" />
          </el-form-item>
          <el-button type="primary" :loading="submitting" :disabled="tickets.length === 0" @click="submit">提交预约</el-button>
        </el-form>
      </section>
      <aside class="side-card">
        <img :src="spot.coverUrl" :alt="spot.name" style="border-radius:12px;height:180px;width:100%;object-fit:cover" />
        <h3>{{ spot.name }}</h3>
        <p>应付 <strong>{{ money(total) }}</strong></p>
        <p class="muted">提交后可在“我的订单”中查看或取消待出行订单。</p>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '../../api'
import { useUserStore } from '../../stores/user'
import { money, priceText } from '../../utils/format'

const route = useRoute()
const router = useRouter()
const user = useUserStore()
const loading = ref(false)
const error = ref('')
const submitting = ref(false)
const spot = ref(null)
const tickets = ref([])
const formRef = ref()
const form = reactive({
  visitDate: '',
  ticketTypeId: null,
  quantity: 1,
  contactName: user.profile?.nickname || '',
  contactPhone: user.profile?.phone || '',
})
const rules = {
  visitDate: [{ required: true, message: '请选择日期', trigger: 'change' }],
  ticketTypeId: [{ required: true, message: '请选择票种', trigger: 'change' }],
  quantity: [{ required: true, message: '请填写数量', trigger: 'change' }],
  contactName: [{ required: true, message: '请填写联系人', trigger: 'blur' }],
  contactPhone: [{ required: true, pattern: /^1\d{10}$/, message: '请输入 11 位手机号', trigger: 'blur' }],
}
const selected = computed(() => tickets.value.find((item) => item.id === form.ticketTypeId))
const total = computed(() => (selected.value ? Number(selected.value.price) * form.quantity : 0))

function shanghaiToday() {
  const text = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Shanghai',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date())
  const [year, month, day] = text.split('-').map(Number)
  return new Date(year, month - 1, day)
}

function disabledDate(date) {
  const today = shanghaiToday()
  const max = new Date(today)
  max.setDate(max.getDate() + 60)
  const day = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  return day < today || day > max
}

async function submit() {
  if (!tickets.value.length) return
  await formRef.value.validate()
  submitting.value = true
  try {
    const order = await api.createOrder({
      spotId: spot.value.id,
      ticketTypeId: form.ticketTypeId,
      visitDate: form.visitDate,
      quantity: form.quantity,
      contactName: form.contactName,
      contactPhone: form.contactPhone,
    })
    ElMessage.success(`预约成功，订单号 ${order.orderNo}`)
    router.push('/orders')
  } finally {
    submitting.value = false
  }
}

async function load() {
  loading.value = true
  error.value = ''
  spot.value = null
  try {
    const data = await api.spot(route.params.id)
    if (!data?.spot || data.spot.status === 0) {
      error.value = '景点不存在或已下架'
      return
    }
    spot.value = data.spot
    tickets.value = data.tickets || []
    form.ticketTypeId = tickets.value[0] ? tickets.value[0].id : null
  } catch (err) {
    error.value = err?.message || '预约信息加载失败'
  } finally {
    loading.value = false
  }
}
onMounted(load)
</script>
