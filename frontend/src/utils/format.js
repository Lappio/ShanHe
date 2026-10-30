export function priceText(value) {
  if (value === null || value === undefined || value === '') return '暂无可预约门票'
  const number = Number(value)
  if (Number.isNaN(number)) return '价格待定'
  if (number <= 0) return '免费'
  return `¥${number.toFixed(0)}`
}

export function money(value) {
  const number = Number(value || 0)
  return `¥${number.toFixed(2)}`
}

export const orderStatusMap = {
  PENDING: '待出行',
  COMPLETED: '已完成',
  CANCELLED: '已取消',
}

export const noteStatusMap = {
  PENDING: '待审核',
  APPROVED: '已通过',
  REJECTED: '已驳回',
}

export function orderStatusText(status) {
  return orderStatusMap[status] || status
}

export function noteStatusText(status) {
  return noteStatusMap[status] || status
}
