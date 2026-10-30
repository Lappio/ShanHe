import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior: () => ({ top: 0 }),
  routes: [
    {
      path: '/',
      component: () => import('../layouts/UserLayout.vue'),
      children: [
        { path: '', name: 'home', component: () => import('../views/HomeView.vue'), meta: { title: '首页' } },
        { path: 'spots', component: () => import('../views/spot/SpotList.vue'), meta: { title: '景点列表' } },
        { path: 'spots/:id', component: () => import('../views/spot/SpotDetail.vue'), meta: { title: '景点详情' } },
        { path: 'book/:id', component: () => import('../views/order/BookView.vue'), meta: { title: '门票预约', auth: true } },
        { path: 'routes', component: () => import('../views/route/RouteList.vue'), meta: { title: '推荐路线' } },
        { path: 'routes/:id', component: () => import('../views/route/RouteDetail.vue'), meta: { title: '路线详情' } },
        { path: 'notes', component: () => import('../views/note/NoteList.vue'), meta: { title: '游记攻略' } },
        { path: 'notes/new', component: () => import('../views/note/NoteEdit.vue'), meta: { title: '发布游记', auth: true } },
        { path: 'notes/:id/edit', component: () => import('../views/note/NoteEdit.vue'), meta: { title: '编辑游记', auth: true } },
        { path: 'notes/:id', component: () => import('../views/note/NoteDetail.vue'), meta: { title: '游记详情' } },
        { path: 'news', component: () => import('../views/news/NewsList.vue'), meta: { title: '资讯公告' } },
        { path: 'news/:id', component: () => import('../views/news/NewsDetail.vue'), meta: { title: '资讯详情' } },
        { path: 'orders', component: () => import('../views/order/OrderList.vue'), meta: { title: '我的订单', auth: true } },
        { path: 'user', component: () => import('../views/user/UserCenter.vue'), meta: { title: '个人中心', auth: true } },
      ],
    },
    { path: '/login', component: () => import('../views/auth/LoginView.vue'), meta: { title: '登录' } },
    { path: '/register', component: () => import('../views/auth/RegisterView.vue'), meta: { title: '注册' } },
    {
      path: '/admin',
      component: () => import('../layouts/AdminLayout.vue'),
      meta: { auth: true, admin: true, title: '管理后台' },
      children: [
        { path: '', redirect: '/admin/dashboard' },
        { path: 'dashboard', component: () => import('../views/admin/DashboardView.vue'), meta: { title: '数据统计' } },
        { path: 'spots', component: () => import('../views/admin/SpotManage.vue'), meta: { title: '景点管理' } },
        { path: 'categories', component: () => import('../views/admin/CategoryManage.vue'), meta: { title: '分类管理' } },
        { path: 'tickets', component: () => import('../views/admin/TicketManage.vue'), meta: { title: '票种管理' } },
        { path: 'routes', component: () => import('../views/admin/RouteManage.vue'), meta: { title: '路线管理' } },
        { path: 'orders', component: () => import('../views/admin/OrderManage.vue'), meta: { title: '订单管理' } },
        { path: 'notes', component: () => import('../views/admin/NoteManage.vue'), meta: { title: '游记审核' } },
        { path: 'comments', component: () => import('../views/admin/CommentManage.vue'), meta: { title: '评论管理' } },
        { path: 'users', component: () => import('../views/admin/UserManage.vue'), meta: { title: '用户管理' } },
        { path: 'banners', component: () => import('../views/admin/BannerManage.vue'), meta: { title: '轮播管理' } },
        { path: 'news', component: () => import('../views/admin/NewsManage.vue'), meta: { title: '资讯管理' } },
      ],
    },
    { path: '/:pathMatch(.*)*', component: () => import('../views/NotFound.vue'), meta: { title: '页面不存在' } },
  ],
})

router.beforeEach((to) => {
  const user = useUserStore()
  const needAuth = to.matched.some((record) => record.meta.auth)
  const needAdmin = to.matched.some((record) => record.meta.admin)
  if (needAuth && !user.isLogin) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }
  if (needAdmin && !user.isAdmin) {
    return { path: '/' }
  }
  return true
})

router.afterEach((to) => {
  const title = to.meta.title
  document.title = title ? `${title} · 山河纪` : '山河纪'
})

export default router
