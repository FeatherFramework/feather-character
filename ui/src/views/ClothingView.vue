<script setup>
import { ref } from "vue";
import ConfigSection from '@/components/ConfigSection.vue';
import { useCategoryStore } from '@/store/category';
import api from "@/api"

const category_store = useCategoryStore();
const disabled = ref(false)

const selectClothes = (data) => {
  disabled.value = true
  api.post("SelectedClothes", {
    data: data,
  }).then(() => {
    disabled.value = false
  })
    .catch((e) => {
      console.log(e.message);
    });
};
</script>

<template>
  <div class="home">
    <div v-for="(value) in category_store.clothing" :key="value.CategoryName" class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded block mb-4" >
        <ConfigSection :disabled="disabled" :data="value" @dataChange="selectClothes"></ConfigSection>
    </div>
    <router-link to="/category" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded block mb-4" >
      Back
    </router-link>
  </div>
</template>