<script setup>
import { ref } from "vue";

import api from "@/api"
import router from "@/router";

const firstname = ref('')
const lastname = ref('')
const dob = ref('')
const sex = ref('male')

const submit = () => {
    api.post("SelectedDetails", {
        data: {
            firstname: firstname.value,
            lastname: lastname.value,
            dob: dob.value,
            sex: sex.value
        }
    }).then(() => {
        router.push('/category')
    })
    .catch((e) => {
        console.log(e.message);
    });
}
</script>

<template>
    <div>
        <form @submit.prevent="submit">
            <div class="grid gap-6 mb-6 md:grid-cols-2">
                <div>
                    <label for="first_name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">First
                        name</label>
                    <input type="text" id="first_name"
                        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                        placeholder="John" required v-model="firstname">
                </div>
                <div>
                    <label for="last_name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Last
                        name</label>
                    <input type="text" id="last_name"
                        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                        placeholder="Doe" required v-model="lastname">
                </div>
            </div>
            <div>
                <label for="dob">Start date:</label>
                <div class="relative max-w-sm">
                    <input type="date" id="start" name="trip-start" v-model="dob" min="1806-01-01" max="1906-01-01" required
                        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
                </div>
            </div>
            <br>
            <hr class="mb-4">
            <div class="flex items-center mb-4">
                <input checked id="default-radio-1" type="radio" value="Male" v-model="sex" name="default-radio"
                    class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600">
                <label for="default-radio-1" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">Male</label>
            </div>
            <div class="flex items-center">
                <input id="default-radio-2" type="radio" value="Female" v-model="sex" name="default-radio"
                    class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600">
                <label for="default-radio-2"
                    class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">Female</label>
            </div>

            <br>
            <hr class="mb-4">
            <button type="submit"
                class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
        </form>

</div></template>
