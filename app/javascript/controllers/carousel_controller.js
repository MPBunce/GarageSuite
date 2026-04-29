import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["slide", "indicator"]
  }

  static get values() {
    return {
      interval: { type: Number, default: 4000 }
    }
  }

  connect() {
    this.element.dataset.carouselEnhanced = "true"
    this.currentIndex = 0
    this.show(this.currentIndex)
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  goTo(event) {
    const nextIndex = Number.parseInt(event.currentTarget.dataset.index, 10)
    if (Number.isNaN(nextIndex)) return

    this.currentIndex = this.normalizeIndex(nextIndex)
    this.show(this.currentIndex)
    this.restartTimer()
  }

  pause() {
    this.stopTimer()
  }

  resume() {
    this.startTimer()
  }

  next() {
    this.currentIndex = this.normalizeIndex(this.currentIndex + 1)
    this.show(this.currentIndex)
  }

  startTimer() {
    if (this.timer || this.slideTargets.length <= 1) return

    this.timer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopTimer() {
    if (!this.timer) return

    clearInterval(this.timer)
    this.timer = null
  }

  restartTimer() {
    this.stopTimer()
    this.startTimer()
  }

  show(activeIndex) {
    this.slideTargets.forEach((slide, index) => {
      const isActive = index === activeIndex
      slide.classList.toggle("opacity-100", isActive)
      slide.classList.toggle("opacity-0", !isActive)
      slide.setAttribute("aria-hidden", (!isActive).toString())
    })

    this.indicatorTargets.forEach((indicator, index) => {
      const isActive = index === activeIndex
      indicator.classList.toggle("bg-white", isActive)
      indicator.classList.toggle("bg-white/40", !isActive)
      indicator.setAttribute("aria-current", isActive ? "true" : "false")
    })
  }

  normalizeIndex(index) {
    const total = this.slideTargets.length
    if (total === 0) return 0

    return ((index % total) + total) % total
  }
}
