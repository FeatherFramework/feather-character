<template>
    <div>
        <div class="primary">
            <div>{{ props.data.CategoryName }}</div>
            <SliderBar :default="-1" :offset="1" :min="-1" :max="Object.keys(props.data.CategoryData).length - 1" @dataChange="handlePrimaryChange"></SliderBar>
        </div>

        <div class="variant">
            <SliderBar :default="0" :offset="1" :reset="change" :min="0" :max="Object.keys(variantOptions).length - 1" @dataChange="handleVariantChange"></SliderBar>
        </div>
    </div>
</template>
  
<script setup>
import SliderBar from '@/components/SliderBar.vue';
import { ref, onMounted, watch } from "vue";

const props = defineProps({
    data: {
        required: true
    }
})

const emit = defineEmits(["dataChange"])

const primarySelection = ref(-1)
const variantSelection = ref(0)

const variantOptions = ref([])
const change = ref(false)

onMounted(() => {
    variantOptions.value = props.data.CategoryData[primarySelection.value] || []
});

const handlePrimaryChange = (e) => {
    primarySelection.value = e
    change.value = !change.value
    
    variantOptions.value = props.data.CategoryData[primarySelection.value] || []
}

const handleVariantChange = (e) => {
    variantSelection.value = e
}

const handleGlobalChange = (prime, variant) => {
    let primaryID = Number(prime) + 1
    let VariantID = Number(variant) + 1

    emit('dataChange', {
        primary: {
            id: primaryID
        },
        variant: {
            id: VariantID,
            ...variantOptions.value[variant] || []
        }
    })
}

watch(primarySelection, (cur) => {
    handleGlobalChange(cur, variantSelection.value)
})

watch(variantSelection, (cur) => {
    handleGlobalChange(primarySelection.value, cur)
})

</script>
  