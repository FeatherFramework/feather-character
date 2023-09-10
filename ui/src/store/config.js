import { defineStore } from 'pinia';

export const useConfigStore = defineStore('ConfigData', {
    state: () => ({
        config: {}
    }),
    actions: {
        storeData(data) {
            this.config = data
        }
    }
})