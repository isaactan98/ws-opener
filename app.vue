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
                  id="grid-password" type="tel" placeholder="Phone Number" @change="removeCharacter()" />
                <p class="text-gray-600 text-xs italic">628123456789</p>
              </div>
            </div>
            <div class="my-3 w-full" v-if="copied !== ''">
              <p class="text-xs text-gray-300">Text Copied</p>
              <div class="flex gap-5">
                <p class="text-gray-800 p-3 rounded bg-gray-400 w-full">{{ copied }}</p>
                <button @click="pasteText()">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                    stroke="currentColor" class="w-6 h-6 text-white">
                    <path stroke-linecap="round" stroke-linejoin="round"
                      d="M8.25 7.5V6.108c0-1.135.845-2.098 1.976-2.192.373-.03.748-.057 1.123-.08M15.75 18H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08M15.75 18.75v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5A3.375 3.375 0 006.375 7.5H5.25m11.9-3.664A2.251 2.251 0 0015 2.25h-1.5a2.251 2.251 0 00-2.15 1.586m5.8 0c.065.21.1.433.1.664v.75h-6V4.5c0-.231.035-.454.1-.664M6.75 7.5H4.875c-.621 0-1.125.504-1.125 1.125v12c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V16.5a9 9 0 00-9-9z" />
                  </svg>
                </button>
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
      copied: ""
    };
  },
  mounted() {
    navigator.clipboard.readText().then((text) => {
      console.log("copied text: ", text);
      this.copied = text;
    });
  },
  methods: {
    openChat() {
      if (this.phone === "") {
        alert("Phone Number is required");
        return;
      } else {
        window.open(`whatsapp://send?phone=${this.phone}&text=`);
      }
    },
    clearInput() {
      this.phone = "";
    },
    removeCharacter() {
      this.phone = this.phone.replace(/[\s+\-()]/g, '');
    },
    pasteText() {
      navigator.clipboard.readText().then((text) => {
        console.log("copied text: ", text);
        this.phone = text;
        this.removeCharacter();
        navigator.clipboard.writeText('')
          .then(() => {
            this.copied = '';
          })
          .catch(err => console.error("Failed to clear clipboard: ", err));
      });
    }
  },
};  
</script>