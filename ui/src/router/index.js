import { createRouter, createWebHashHistory } from 'vue-router'
import DetailsView from '../views/DetailsView.vue'


const routes = [
  {
    path: '/',
    name: 'home',
    component: DetailsView
  },
  {
    path: '/category',
    name: 'category',
    component: () => import('../views/CategoryView.vue')
  },
  {
    path: '/clothing',
    name: 'clothing',
    component: () => import('../views/ClothingView.vue')
  },
  {
    path: '/appearance',
    name: 'appearance',
    component: () => import('../views/AppearanceView.vue')
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
