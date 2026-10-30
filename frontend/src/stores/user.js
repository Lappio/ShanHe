import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('shanhe_token') || '',
    profile: readProfile(),
  }),
  getters: {
    isLogin: (state) => Boolean(state.token),
    isAdmin: (state) => state.profile?.role === 'ADMIN',
  },
  actions: {
    setSession(token, profile) {
      this.token = token
      this.profile = profile
      localStorage.setItem('shanhe_token', token)
      localStorage.setItem('shanhe_profile', JSON.stringify(profile))
    },
    setProfile(profile) {
      this.profile = profile
      localStorage.setItem('shanhe_profile', JSON.stringify(profile))
    },
    logout() {
      this.token = ''
      this.profile = null
      localStorage.removeItem('shanhe_token')
      localStorage.removeItem('shanhe_profile')
    },
  },
})

function readProfile() {
  try {
    return JSON.parse(localStorage.getItem('shanhe_profile') || 'null')
  } catch {
    return null
  }
}
