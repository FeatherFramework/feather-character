<script setup>
import { ref } from "vue";

const HomeCategories = ref([
  {
    name: "Appearance",
    to: '/'
  },
  {
    name: "Clothing",
    to: '/clothing'
  }
])

</script>

<template>
  <div class="home">
      <router-link v-for="(value) in HomeCategories" :key="value.name" active-class="active" :to="value.to"
        class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded block mb-4">
        {{ value.name }}
      </router-link>
  </div>
</template>
