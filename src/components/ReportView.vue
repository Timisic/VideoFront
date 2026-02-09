<template>
  <div class="report-container">
    <div class="report-content" id="report-content">
      <div class="report-header">
        <h1>心理测评报告</h1>
        <div class="report-subtitle">基于大五人格理论的分析结果</div>
      </div>
      
      <div class="chart-section">
        <div class="chart-wrapper">
          <div ref="radarChart" class="chart"></div>
        </div>
      </div>
      
      <div class="dimensions-section">
        <div 
          v-for="(dimension, key) in data" 
          :key="key"
          class="dimension-card"
        >
          <div class="dimension-header">
            <h3>{{ dimension.dimension_name }}</h3>
            <div class="dimension-score">
              <span class="score-value">{{ (dimension.score * 100).toFixed(0) }}</span>
              <span class="score-label">分</span>
            </div>
          </div>
          <div class="dimension-result">{{ dimension.result }}</div>
          <div class="dimension-interpretation">{{ dimension.interpretation }}</div>
        </div>
      </div>
    </div>
    
    <div class="report-actions">
      <el-button type="primary" size="large" @click="handleExportPdf">
        导出 PDF
      </el-button>
      <el-button size="large" @click="handleRetry">
        重新测评
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { exportPdf } from '../utils/exportPdf'

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['retry'])
const radarChart = ref(null)

onMounted(async () => {
  await nextTick()
  initRadarChart()
})

function initRadarChart() {
  if (!radarChart.value) return
  
  const chart = echarts.init(radarChart.value)
  
  const dimensions = Object.values(props.data)
  const indicator = dimensions.map(d => ({
    name: d.dimension_name,
    max: 100
  }))
  
  const values = dimensions.map(d => d.score * 100)
  
  const option = {
    radar: {
      indicator: indicator,
      shape: 'polygon',
      splitNumber: 4,
      axisName: {
        color: '#606266',
        fontSize: 14
      },
      splitLine: {
        lineStyle: {
          color: '#e4e7ed'
        }
      },
      splitArea: {
        areaStyle: {
          color: ['#f9fafc', '#fff']
        }
      }
    },
    series: [{
      type: 'radar',
      data: [{
        value: values,
        name: '人格特质',
        areaStyle: {
          color: 'rgba(64, 158, 255, 0.2)'
        },
        lineStyle: {
          color: '#409eff',
          width: 2
        },
        itemStyle: {
          color: '#409eff'
        }
      }]
    }]
  }
  
  chart.setOption(option)
  
  window.addEventListener('resize', () => {
    chart.resize()
  })
}

async function handleExportPdf() {
  await exportPdf('report-content')
}

function handleRetry() {
  emit('retry')
}
</script>

<style scoped>
.report-container {
  width: 100vw;
  height: 100vh;
  overflow-y: auto;
  background: #f5f7fa;
}

.report-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  background: #fff;
  min-height: calc(100vh - 100px);
}

.report-header {
  text-align: center;
  margin-bottom: 40px;
  padding-bottom: 24px;
  border-bottom: 2px solid #e4e7ed;
}

.report-header h1 {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 12px;
}

.report-subtitle {
  font-size: 16px;
  color: #909399;
}

.chart-section {
  margin-bottom: 40px;
}

.chart-wrapper {
  display: flex;
  justify-content: center;
}

.chart {
  width: 600px;
  height: 500px;
}

.dimensions-section {
  display: grid;
  gap: 24px;
}

.dimension-card {
  padding: 24px;
  background: #fafafa;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
}

.dimension-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.dimension-header h3 {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.dimension-score {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.score-value {
  font-size: 28px;
  font-weight: 700;
  color: #409eff;
}

.score-label {
  font-size: 14px;
  color: #909399;
}

.dimension-result {
  font-size: 16px;
  font-weight: 600;
  color: #606266;
  margin-bottom: 12px;
}

.dimension-interpretation {
  font-size: 14px;
  line-height: 1.8;
  color: #606266;
}

.report-actions {
  position: sticky;
  bottom: 0;
  background: #fff;
  padding: 20px;
  border-top: 1px solid #e4e7ed;
  display: flex;
  justify-content: center;
  gap: 16px;
}
</style>
