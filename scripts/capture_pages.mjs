import { createRequire } from 'module'
import { fileURLToPath } from 'url'
import fs from 'fs'
import path from 'path'

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(here, '..')

function loadPlaywright() {
  const explicit = process.env.PLAYWRIGHT_PACKAGE
  const candidates = [
    explicit,
    path.join(root, 'frontend', 'node_modules', 'playwright', 'package.json'),
    path.join(root, 'node_modules', 'playwright', 'package.json'),
  ].filter(Boolean)
  for (const pkg of candidates) {
    if (fs.existsSync(pkg)) return createRequire(pkg)('playwright')
  }
  console.error('找不到 playwright。请在 frontend 安装依赖，或设置 PLAYWRIGHT_PACKAGE 指向 playwright 的 package.json。此脚本不改数据库。')
  process.exit(1)
}

const { chromium } = loadPlaywright()

const OUT = path.join(root, 'docs', 'screenshots')
const ART = process.env.SCREENSHOT_DIR || ''
const BASE = process.env.SHANHE_WEB || 'http://127.0.0.1:43123'
fs.mkdirSync(OUT, { recursive: true })
if (ART) fs.mkdirSync(ART, { recursive: true })

const browser = await chromium.launch({ headless: true })
const context = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  locale: 'zh-CN',
  deviceScaleFactor: 1,
})
const page = await context.newPage()
const problems = []
page.on('pageerror', (error) => problems.push(`pageerror ${error.message}`))
page.on('response', (response) => {
  const url = response.url()
  if (url.includes('/api/') && response.status() >= 400) {
    problems.push(`http ${response.status()} ${url}`)
  }
})

async function shot(name) {
  await page.waitForTimeout(500)
  const file = path.join(OUT, `${name}.png`)
  await page.screenshot({ path: file, fullPage: true })
  if (ART) fs.copyFileSync(file, path.join(ART, `${name}.png`))
  console.log('shot', name)
}

async function open(url, ready) {
  await page.goto(BASE + url, { waitUntil: 'networkidle', timeout: 30000 })
  if (ready) await page.getByText(ready).first().waitFor({ timeout: 15000 })
}

async function login(username, password) {
  await open('/login', '登录')
  const inputs = page.locator('.auth-card input')
  await inputs.nth(0).fill(username)
  await inputs.nth(1).fill(password)
  await page.getByRole('button', { name: '登录' }).click()
  await page.waitForTimeout(800)
}

try {
  await open('/', '当季热门')
  await shot('01-home')

  await open('/spots', '景点')
  await page.getByPlaceholder('故宫 / 杭州').fill('西湖')
  await page.getByRole('button', { name: '应用筛选' }).click()
  await page.getByText('杭州').first().waitFor({ timeout: 10000 })
  await shot('02-spots')

  await open('/spots/1', '故宫博物院')
  await shot('03-spot-detail')

  await open('/routes', '推荐路线')
  await shot('04-routes')

  await open('/routes/1', '每日安排')
  await shot('05-route-detail')

  await open('/notes', '游记攻略')
  await shot('06-notes')

  await open('/notes/1', '点赞')
  await shot('07-note-detail')

  await open('/news', '资讯公告')
  await shot('08-news')

  await open('/news/1')
  await page.locator('h2').first().waitFor()
  await shot('09-news-detail')

  await open('/login', '演示账号')
  await shot('10-login')

  await open('/register', '注册并登录')
  await shot('11-register')

  const stamp = String(Date.now()).slice(-6)
  const username = `youke${stamp}`
  const reg = page.locator('.auth-card input')
  await reg.nth(0).fill(username)
  await reg.nth(1).fill('验收游客')
  await reg.nth(2).fill('13900001111')
  await reg.nth(3).fill('user123')
  await page.getByRole('button', { name: '注册并登录' }).click()
  await page.waitForURL('**/', { timeout: 15000 })
  await page.getByText('验收游客').first().waitFor({ timeout: 10000 })
  await shot('12-registered-home')
  console.log('registered', username)

  await page.locator('.user-trigger, .el-dropdown').first().click()
  await page.getByText('退出登录').click()
  await page.waitForTimeout(400)

  await login('linwan', 'user123')
  await page.waitForURL((url) => !url.pathname.startsWith('/login'), { timeout: 15000 })
  await open('/book/1', '门票预约')
  await page.locator('.el-date-editor').click()
  const day = page.locator('.el-picker-panel td.available').filter({ hasText: /^27$/ }).first()
  await day.click()
  await page.locator('.ticket').first().click()
  const phone = page.getByPlaceholder ? page.locator('input').filter({ hasNot: page.locator('[type=hidden]') }) : null
  const phoneInput = page.locator('.el-form-item').filter({ hasText: '手机号' }).locator('input')
  if ((await phoneInput.inputValue()) === '') await phoneInput.fill('13800001001')
  const nameInput = page.locator('.el-form-item').filter({ hasText: '联系人' }).locator('input')
  if ((await nameInput.inputValue()) === '') await nameInput.fill('林晓晚')
  await shot('13-book')
  await page.getByRole('button', { name: '提交预约' }).click()
  await page.waitForURL('**/orders', { timeout: 15000 })
  await page.getByRole('heading', { name: '我的订单' }).waitFor()
  await shot('14-orders')
  console.log('booked')

  await open('/user', '个人中心')
  await shot('15-user')
  await page.getByRole('tab', { name: '收藏' }).click()
  await page.waitForTimeout(500)
  await shot('16-favorites')
  await page.getByRole('tab', { name: '我的游记' }).click()
  await page.waitForTimeout(400)
  await shot('17-my-notes')

  await open('/notes/new', '发布游记')
  await page.locator('.el-form-item').filter({ hasText: '标题' }).locator('input').fill('浏览器走查：午后的中轴线')
  await page.locator('textarea').fill('从午门进，沿着中轴线走到太和殿，再从神武门离开。这篇游记由页面走查提交，用来确认发布后进入待审核，管理员通过后才会出现在公开列表。')
  await shot('18-note-edit')
  await page.getByRole('button', { name: '提交审核' }).click()
  await page.waitForURL(/\/notes\/\d+$/, { timeout: 15000 })
  await page.getByRole('heading', { name: '浏览器走查：午后的中轴线' }).waitFor({ timeout: 15000 })
  await shot('19-note-submitted')
  console.log('note', page.url())

  await context.clearCookies()
  await page.evaluate(() => localStorage.clear())
  await login('admin', 'admin123')
  await page.waitForURL('**/admin/**', { timeout: 15000 })
  await page.locator('canvas').first().waitFor({ timeout: 15000 })
  await page.waitForTimeout(900)
  await shot('20-admin-dashboard')

  await open('/admin/spots', '景点')
  await shot('21-admin-spots')
  await open('/admin/orders', '订单')
  await shot('22-admin-orders')
  await open('/admin/notes', '待审核')
  await page.getByText('浏览器走查：午后的中轴线').waitFor({ timeout: 10000 })
  await shot('23-admin-notes')
  const row = page.locator('tr', { hasText: '浏览器走查：午后的中轴线' })
  await row.getByRole('button', { name: '通过' }).click()
  await page.waitForTimeout(800)
  await shot('24-admin-notes-approved')
  console.log('approved')

  await open('/admin/users', '用户')
  await shot('25-admin-users')
  await open('/admin/news', '资讯')
  await shot('26-admin-news')
  await open('/admin/categories', '分类')
  await shot('27-admin-categories')
  await open('/admin/tickets', '票种')
  await shot('28-admin-tickets')
  await open('/admin/routes', '路线')
  await shot('29-admin-routes')
  await open('/admin/comments', '评论')
  await shot('30-admin-comments')
  await open('/admin/banners', '轮播')
  await shot('31-admin-banners')

  await page.setViewportSize({ width: 390, height: 844 })
  await open('/', '当季热门')
  await shot('32-home-mobile')
  await open('/spots', '景点')
  await shot('33-spots-mobile')

  const publicNote = await page.request.get(BASE + '/api/notes?page=1&size=10')
  console.log('public notes status', publicNote.status())
} catch (error) {
  const fail = path.join(OUT, 'failure.png')
  await page.screenshot({ path: fail, fullPage: true }).catch(() => {})
  console.error('FAILED', page.url(), error)
  process.exitCode = 1
} finally {
  console.log('problems', problems.slice(0, 30))
  await browser.close()
}
