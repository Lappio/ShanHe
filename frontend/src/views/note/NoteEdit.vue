<template>
  <div class="wrap page">
    <h2 class="serif">{{ id ? '编辑游记' : '发布游记' }}</h2>
    <p class="muted">提交后进入待审核。通过之前不会出现在公开列表。正文按纯文本保存。</p>
    <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="video-block">
      <el-form-item label="标题" prop="title"><el-input v-model="form.title" maxlength="120" show-word-limit /></el-form-item>
      <el-form-item label="关联景点">
        <el-select v-model="form.spotId" clearable filterable placeholder="可选" style="width:100%">
          <el-option v-for="item in spots" :key="item.id" :label="`${item.name} · ${item.province}`" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="封面地址">
        <el-input v-model="form.coverUrl" placeholder="留空则使用景点封面，也可粘贴媒体包地址" />
      </el-form-item>
      <el-form-item label="正文" prop="content">
        <el-input v-model="form.content" type="textarea" :rows="12" maxlength="8000" show-word-limit />
      </el-form-item>
      <el-button type="primary" :loading="saving" @click="save">提交审核</el-button>
    </el-form>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '../../api'

const route = useRoute()
const router = useRouter()
const id = computed(() => route.params.id)
const formRef = ref()
const saving = ref(false)
const spots = ref([])
const form = reactive({ title: '', content: '', coverUrl: '', spotId: null })
const rules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, min: 20, message: '正文至少 20 字', trigger: 'blur' }],
}

async function save() {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = { ...form, spotId: form.spotId || null, coverUrl: form.coverUrl || null }
    if (id.value) {
      await api.updateNote(id.value, payload)
      ElMessage.success('已重新提交审核')
      router.push(`/notes/${id.value}`)
    } else {
      const noteId = await api.createNote(payload)
      ElMessage.success('已提交，等待审核')
      router.push(`/notes/${noteId}`)
    }
  } finally {
    saving.value = false
  }
}

async function loadForm() {
  const page = await api.spots({ page: 1, size: 50, sort: 'new' })
  spots.value = page.records
  if (id.value) {
    const note = await api.note(id.value)
    form.title = note.title
    form.content = note.content
    form.coverUrl = note.coverUrl || ''
    form.spotId = note.spotId
  } else {
    form.title = ''
    form.content = ''
    form.coverUrl = ''
    form.spotId = null
  }
}
watch(() => route.params.id, loadForm)
onMounted(loadForm)
</script>
