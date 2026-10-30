// Serves frontend/dist and proxies /api to the backend.
// Same routes as frontend/nginx.conf: /api goes to the backend, other paths
// fall back to index.html so the Vue router works.
import fs from 'node:fs'
import http from 'node:http'
import path from 'node:path'

const dist = path.resolve(process.env.SHANHE_DIST || 'frontend/dist')
const port = Number(process.env.SHANHE_FRONTEND_PORT || '43123')
const backendHost = process.env.SHANHE_BACKEND_HOST || '127.0.0.1'
const backendPort = Number(process.env.SHANHE_BACKEND_PORT || '8088')

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
  '.map': 'application/json',
}

function fileFor(urlPath) {
  let decoded = urlPath
  try {
    decoded = decodeURIComponent(urlPath)
  } catch {
    return null
  }
  const relative = decoded.replace(/^\/+/, '')
  const full = path.resolve(dist, relative)
  const root = dist.endsWith(path.sep) ? dist : dist + path.sep
  if (full !== dist && !full.startsWith(root)) return null
  return full
}

function sendFile(res, file) {
  const type = mime[path.extname(file).toLowerCase()] || 'application/octet-stream'
  res.writeHead(200, { 'content-type': type })
  fs.createReadStream(file).pipe(res)
}

function proxy(req, res) {
  const headers = { ...req.headers }
  headers['x-real-ip'] = req.socket.remoteAddress || ''
  const upstream = http.request({
    host: backendHost,
    port: backendPort,
    path: req.url,
    method: req.method,
    headers,
  }, (upstreamResponse) => {
    res.writeHead(upstreamResponse.statusCode || 502, upstreamResponse.headers)
    upstreamResponse.pipe(res)
  })
  upstream.setTimeout(20000, () => upstream.destroy())
  upstream.on('error', () => {
    if (res.headersSent) {
      res.end()
      return
    }
    res.writeHead(502, { 'content-type': 'text/plain; charset=utf-8' })
    res.end('Bad gateway')
  })
  req.pipe(upstream)
}

const server = http.createServer((req, res) => {
  const urlPath = (req.url || '/').split('?')[0]
  if (urlPath === '/api' || urlPath.startsWith('/api/')) {
    proxy(req, res)
    return
  }
  let file = fileFor(urlPath)
  if (file && fs.existsSync(file) && fs.statSync(file).isDirectory()) {
    file = path.join(file, 'index.html')
  }
  if (!file || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
    file = path.join(dist, 'index.html')
  }
  if (!fs.existsSync(file)) {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' })
    res.end('Not found')
    return
  }
  sendFile(res, file)
})

server.listen(port, '0.0.0.0', () => {
  console.log('frontend listening on ' + port + ', api -> ' + backendHost + ':' + backendPort)
})
server.on('error', (error) => {
  console.error(error.message)
  process.exit(1)
})
