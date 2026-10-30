import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'

const http = axios.create({
  baseURL: '/api',
  timeout: 15000,
})

http.interceptors.request.use((config) => {
  const user = useUserStore()
  if (user.token) {
    config.headers.Authorization = `Bearer ${user.token}`
  }
  return config
})

http.interceptors.response.use(
  (response) => {
    const body = response.data
    if (body.code !== 0) {
      if (body.code === 401) {
        redirectLogin()
      } else {
        ElMessage.error(body.message || '请求失败')
      }
      return Promise.reject(body)
    }
    return body.data
  },
  (error) => {
    const status = error.response?.status
    if (status === 401) {
      redirectLogin()
    } else {
      ElMessage.error(error.response?.data?.message || '网络异常，请稍后重试')
    }
    return Promise.reject(error)
  },
)

function redirectLogin() {
  const user = useUserStore()
  user.logout()
  const path = location.pathname + location.search
  if (!path.startsWith('/login')) {
    location.assign(`/login?redirect=${encodeURIComponent(path)}`)
  }
}

export default http
