<template>
  <Transition name="bounce">
    <div id="content" class="centerit text-white mx-auto px-10 pt-12 max-w-sm rounded overflow-hidden aspect-[1/2]"
      v-if="visible || devmode">
      <div class="px-6 main-view">
        <RouterView></RouterView>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import api from "./api";
import { ref, onMounted, onUnmounted } from "vue";
import "@/assets/styles/main.css";
import { useCategoryStore } from '@/store/category';

const devmode = ref(false);
const visible = ref(false);
const category_store = useCategoryStore();


onMounted(() => {
  window.addEventListener("message", onMessage);
});

onUnmounted(() => {
  window.removeEventListener("message", onMessage);
});

const onMessage = (event) => {
  switch (event.data.type) {
    case "toggle":
      visible.value = event.data.visible;
      category_store.storeCategoryData('clothing', event.data.clothing)

      api
        .post("UpdateState", {
          state: visible.value,
        })
        .catch((e) => {
          console.log(e.message);
        });
      break;
    default:
      break;
  }
};
</script>

<style>
@font-face {
  font-family: rdrlino;
  src: url(assets/fonts/rdrlino-regular.ttf);
}

@font-face {
  font-family: chinarocks;
  src: url(assets/fonts/chinese-rocks.ttf);
}

::-webkit-scrollbar {
  width: 6px;
}

/* Track */
::-webkit-scrollbar-track {
  background: #f1f1f1;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: #888;
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: #555;
}

#app {
  font-family: rdrlino;
  touch-action: manipulation;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #fff;
  overflow: hidden;
}

body {
  overflow: hidden;
}

.chinarocks {
  font-family: chinarocks !important;
}

.centerit {
  position: absolute;
  right: 0;
  top: 50%;

  transform: translateY(-50%);
}


#content {
  width: 60vh;
  height: 80vh;

  max-height: 600px;
  z-index: 99999;

  position: absolute;
  right: 0;
  top: 50%;


  transform: translateY(-50%);
}


#content::before {
  content: "";
  position: absolute;
  width: 98%;
  height: 100%;
  top: 0px;
  bottom: 0;
  right: 0;
  left: 0px;
  z-index: -1;
  background-size: cover;
  background-image: url(assets/inkroller.png);
  background-repeat: no-repeat;
  transform: rotate(180deg);
}

.main-view {
  height: 84%;
  overflow-y: auto;
}

.active svg {
  color: indianred;
  cursor: pointer;
}


.bounce-enter-active {
  animation: bounce-in 0.5s;
}

.bounce-leave-active {
  animation: bounce-in 0.5s reverse;
}

@keyframes bounce-in {
  0% {
    transform: translate(40vw, -50%);
  }

  50% {
    transform: translateX(20vw, -50%);
  }

  100% {
    transform: translateX(0, -50%);
  }
}</style>
