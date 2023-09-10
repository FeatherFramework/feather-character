<template>
    <div>
        <input id="minmax-range" type="range" :min="props.min" :max="props.max" v-model="curentval"
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700">
        <label for="minmax-range" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">{{ Number(curentval) + props.offset
        }}</label>
    </div>
</template>
  
<script setup>
import { ref, watch } from "vue";


const emit = defineEmits(["dataChange"])

const props = defineProps({
    // options: {
    //     required: true
    // },
    default: {
        required: false,
        default: 0
    },
    min: {
        required: false,
        default: 0
    },
    max: {
        required: false,
        default: 10
    },
    reset: {
        required: false,
        default: false
    },
    offset: {
        required: false,
        default: 0
    }
})

const curentval = ref(props.default)

watch(curentval, (newVal) => {
    if (newVal) {
        emit('dataChange', newVal)
    }
})

watch(() => props.reset, () => {
    curentval.value = props.default
})

</script>
  