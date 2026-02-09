import html2canvas from 'html2canvas'
import jsPDF from 'jspdf'

export async function exportPdf(elementId) {
  try {
    const element = document.getElementById(elementId)
    if (!element) {
      throw new Error('Element not found')
    }
    
    const canvas = await html2canvas(element, {
      scale: 2,
      useCORS: true,
      logging: false
    })
    
    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF('p', 'mm', 'a4')
    
    const pdfWidth = pdf.internal.pageSize.getWidth()
    const pdfHeight = (canvas.height * pdfWidth) / canvas.width
    
    pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight)
    pdf.save('心理测评报告.pdf')
  } catch (error) {
    console.error('Failed to export PDF:', error)
    throw error
  }
}
