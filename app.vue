<template>
  <div class="bg-black min-h-screen grid place-content-center">
    <div class="container mx-auto ">
      <div class=" max-w-6xl p-5">
        <h1 class="text-3xl font-bold text-center text-white">Open WhatsApp Chat</h1>
        <div class="grid place-items-center mt-10">
          <div class="w-full max-w-lg">
            <div class="flex flex-wrap -mx-3 mb-6">
              <div class="w-full px-3">
                <label class="block uppercase tracking-wide text-white text-xs font-bold mb-2" for="grid-password">
                  Phone Number
                </label>
                <input v-model="phone"
                  class="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white"
                  id="grid-password" type="text" placeholder="Phone Number" />
                <p class="text-gray-600 text-xs italic">628123456789</p>
              </div>
            </div>
            <div class="flex justify-center gap-5">
              <button @click="openChat"
                class="bg-green-700 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-full focus:outline-none focus:shadow-outline"
                type="button">
                Open Chat
              </button>
              <button class="bg-white text-gray-700 rounded-full py-2 px-4" @click="clearInput()">
                Clear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: "App",
  head() {
    return {
      title: "Open WhatsApp Chat",
    };
  },
  data() {
    return {
      phone: "",
    };
  },
  methods: {
    openChat() {
      if (this.phone === "") {
        alert("Phone Number is required");
        return;
      } else {
        window.open(`whatsapp://send?phone=${this.phone}&text=Hello%20World!`);
      }
    },
    clearInput() {
      this.phone = "";
    }
  },
};  
</script>