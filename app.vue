<template>
  <!-- Top-aligned, not centred: a centred column jumps up the moment the
       phone keyboard opens, on every single use. -->
  <main
    class="stage min-h-[100svh] bg-hull px-6 pb-14 pt-[clamp(2.5rem,10vh,6rem)]"
    :class="{ 'stage--lit': hasDigits }"
  >
    <form
      class="mx-auto w-full min-w-0 max-w-[30rem]"
      novalidate
      @submit.prevent="openChat"
    >
      <!-- The pitch is for the first visit. Once the keyboard is up the user is
           mid-task and needs the controls, not the headline. -->
      <h1
        class="text-[clamp(2.25rem,10vw,3.25rem)] font-bold leading-[0.95] tracking-[-0.035em] [@media(max-height:640px)]:hidden"
      >
        Open a chat<br />without saving<br />the number.
      </h1>

      <div class="mt-11 [@media(max-height:640px)]:mt-0">
        <label
          for="phone"
          class="block font-mono text-[11px] uppercase tracking-[0.16em] text-muted"
        >
          Phone number
        </label>

        <input
          id="phone"
          ref="inputEl"
          v-model="phone"
          type="tel"
          inputmode="tel"
          autocomplete="tel"
          spellcheck="false"
          placeholder="628123456789"
          class="mt-3 w-full rounded-md border bg-hull-raised px-4 py-3.5 font-mono text-lg tracking-[0.06em] text-paper transition-colors duration-200 hover:border-muted/60"
          :class="
            error
              ? 'border-signal focus-visible:outline-signal'
              : 'border-rule focus:border-lcd'
          "
          :aria-invalid="error ? 'true' : 'false'"
          aria-describedby="phone-hint phone-error"
        />

        <p
          id="phone-hint"
          class="mt-2.5 text-[13px] leading-snug text-muted [@media(max-height:640px)]:hidden"
        >
          Country code first, no leading zero. Paste it however it came —
          spaces, dashes and <span class="font-mono">+</span> are ignored.
        </p>

        <p
          v-if="error"
          id="phone-error"
          role="alert"
          class="mt-2.5 font-mono text-[12px] tracking-[0.02em] text-signal"
        >
          {{ error }}
        </p>
      </div>

      <!-- Clipboard tray: the fastest path from a copied number to a chat. -->
      <div
        v-if="copied !== ''"
        class="mt-5 rounded-md border border-lcd/35 bg-hull-raised p-4"
      >
        <p class="font-mono text-[11px] uppercase tracking-[0.16em] text-lcd">
          On your clipboard
        </p>
        <div class="mt-3 flex items-center gap-3">
          <p class="min-w-0 flex-1 truncate font-mono text-sm text-paper">
            {{ copied }}
          </p>
          <button
            type="button"
            class="flex shrink-0 items-center gap-2 rounded bg-lcd px-3.5 py-2 font-mono text-[11px] uppercase tracking-[0.14em] text-hull transition-colors duration-200 hover:bg-lcd-bright active:bg-lcd-bright"
            @click="pasteText"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.75"
              stroke="currentColor"
              class="h-3.5 w-3.5"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M8.25 7.5V6.108c0-1.135.845-2.098 1.976-2.192.373-.03.748-.057 1.123-.08M15.75 18H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08M15.75 18.75v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5A3.375 3.375 0 006.375 7.5H5.25m11.9-3.664A2.251 2.251 0 0015 2.25h-1.5a2.251 2.251 0 00-2.15 1.586m5.8 0c.065.21.1.433.1.664v.75h-6V4.5c0-.231.035-.454.1-.664M6.75 7.5H4.875c-.621 0-1.125.504-1.125 1.125v12c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V16.5a9 9 0 00-9-9z"
              />
            </svg>
            Use it
          </button>
        </div>
      </div>

      <!-- Signature: the readout. Shows the exact digits WhatsApp receives. -->
      <div class="mt-8 [@media(max-height:640px)]:mt-4">
        <div class="flex items-baseline justify-between gap-4">
          <p
            class="font-mono text-[11px] uppercase tracking-[0.16em] text-muted"
          >
            WhatsApp will dial
          </p>
          <p
            v-if="hasDigits"
            class="font-mono text-[11px] tracking-[0.06em] text-muted"
          >
            {{ dialled.length }} digits
          </p>
        </div>

        <div class="lcd mt-3" :class="{ 'lcd--lit': hasDigits }">
          <p
            class="lcd__value min-w-0 break-all font-mono text-[clamp(1.25rem,6.2vw,1.75rem)] tracking-[0.12em]"
          >
            <!-- The all-segments-on row belongs to the idle display only. Behind
                 a real number it reads as digits WhatsApp would dial, which is
                 the one thing this readout exists to rule out. -->
            <span v-if="hasDigits">{{ dialled }}</span>
            <span v-else class="lcd__ghost" aria-hidden="true">{{ GHOST }}</span>
          </p>
        </div>
      </div>

      <div class="mt-8 flex gap-3 [@media(max-height:640px)]:mt-4">
        <span class="sr-only" aria-live="polite">{{ readoutStatus }}</span>
        <button
          type="submit"
          class="flex-1 rounded-md bg-lcd px-5 py-3.5 text-[15px] font-semibold tracking-[-0.01em] text-hull transition-colors duration-200 hover:bg-lcd-bright active:bg-lcd-bright"
        >
          Open chat
        </button>
        <button
          type="button"
          class="rounded-md border border-rule px-5 py-3.5 text-[15px] font-medium text-muted transition-colors duration-200 hover:border-muted hover:text-paper active:border-muted active:text-paper"
          @click="clearInput"
        >
          Clear
        </button>
      </div>
    </form>
  </main>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";

// An all-segments-on row, the way an idle LCD shows its unused segments.
const GHOST = "8".repeat(13);

const phone = ref("");
const copied = ref("");
const error = ref("");
const inputEl = ref<HTMLInputElement | null>(null);

// Strip the characters phone numbers arrive punctuated with.
function normalize(value: string) {
  return value.replace(/[\s+\-()]/g, "");
}

// The field keeps what the user actually pasted, so they can check it against
// wherever it came from. Only the readout and the link get the dialled form —
// which is what makes the readout worth looking at.
const dialled = computed(() => normalize(phone.value));
const hasDigits = computed(() => dialled.value.length > 0);

const readoutStatus = computed(() =>
  hasDigits.value
    ? `WhatsApp will dial ${dialled.value.split("").join(" ")}. ${
        dialled.value.length
      } digits.`
    : "No number entered yet."
);

watch(phone, () => {
  if (dialled.value !== "") error.value = "";
});

// Reading the clipboard needs permission and a secure context, and several
// browsers refuse outright. A refusal just means no suggestion to offer.
async function readClipboard(): Promise<string> {
  if (!navigator.clipboard?.readText) return "";
  try {
    return await navigator.clipboard.readText();
  } catch {
    return "";
  }
}

onMounted(async () => {
  copied.value = await readClipboard();
});

function openChat() {
  if (dialled.value === "") {
    error.value = "Enter a phone number first.";
    inputEl.value?.focus();
    return;
  }
  window.open(`whatsapp://send?phone=${dialled.value}&text=`);
}

function clearInput() {
  phone.value = "";
  error.value = "";
  inputEl.value?.focus();
}

async function pasteText() {
  const text = await readClipboard();
  if (!text) return;
  phone.value = text;
  // Clear the clipboard so the same number is not suggested again.
  try {
    await navigator.clipboard.writeText("");
  } finally {
    copied.value = "";
  }
}
</script>
