import { defineStore } from 'pinia';

export const useCategoryStore = defineStore('CategoryData', {
    state: () => ({
        clothing: null
    }),
    getters: {
    },
    actions: {
        storeCategoryData(type, data) {
            this[type] = data
        }
    }
})