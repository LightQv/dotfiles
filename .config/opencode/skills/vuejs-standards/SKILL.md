---
name: vuejs-standards
description: Use when working with Vue 3 projects, including .vue files, Vue dependencies, Vite, Pinia, Vue Router, Vuetify, linting, formatting, tests, or builds.
---

## 1. Architecture & Organization

### 1.1 Project Structure Policy

**Crucial:** Do not enforce a specific structure blindly.

1.  **Existing Projects:** Repository code, package scripts, lockfile, and tool configuration are the source of truth. Match the existing architecture and JavaScript or TypeScript choice.
2.  **New Projects:** explicitly ASK the user which structure they prefer:
    - **Feature-Driven (Recommended for Scale):** Group by domain (`features/auth/{components,views,store}`).
    - **Layer-Driven (Simple):** Group by type (`src/components`, `src/views`).
3.  **Typing**: In TypeScript projects, preserve strict typing and avoid `any` unless an existing boundary requires it. In JavaScript projects, do not migrate files to TypeScript without a concrete requirement.

### 1.2 Naming Conventions

- **Components:** Strict **PascalCase** and **Multi-word** (e.g., `UserProfile.vue`, `AppButton.vue`).
- **Composables:** **camelCase** prefixed with `use` (e.g., `useAuth.ts`, `useWindowScroll.ts`).
- **Stores:** **camelCase** prefixed with `use` and suffixed with `Store` (e.g., `useUserStore.ts`).
- **Files:** Filenames must match the export name exactly.

### 1.3 Single Source of Truth

- **Logic Extraction:** If a component's `<script setup>` exceeds ~200 lines, extract business logic into a Composable.
- **DRY Principle:** heavily rely on **Composables** for shared logic.
- **Global State:** Use **Pinia** for data shared across the entire app (User session, Theme, Permissions...).
- **Local State:** Use `ref`/`reactive` inside components or Composables for ephemeral state.

---

## 2. Performance Standards

### 2.1 Optimistic UI

Update the UI _before_ the API response to ensure a "snappy" experience.
**Pattern:**

```typescript
async function toggleLike(post: Post): Promise<void> {
  const originalState = post.isLiked;
  // 1. Optimistic Update
  post.isLiked = !post.isLiked;

  try {
    // 2. API Call
    await api.posts.like(post.id);
  } catch (e) {
    // 3. Rollback on Error
    post.isLiked = originalState;
    showError("Action failed");
  }
}
```

### 2.2 Lazy Loading (Code Splitting)

Reduce initial bundle size by deferring non-critical assets.

**Routes:**
Always lazy-load route components:

```typescript
// router.ts
component: () => import("@/views/Dashboard.vue");
```

**Heavy Components:**
Use `defineAsyncComponent` for modals, heavy charts, or items below the fold:

```typescript
import { defineAsyncComponent } from "vue";
const HeavyChart = defineAsyncComponent(() => import("./HeavyChart.vue"));
```

### 2.3 Rendering Optimization

- **v-memo:** Use `v-memo="[dep1, dep2]"` for large lists or complex sub-trees that rarely change.
- **Stable Keys:** NEVER use array index as `:key`. Always use a unique ID (`:key="item.id"`).
- **v-once:** Use for static content that never changes after initial render.

If uncertain, ask the developer for his desire.

---

## 3. Component Implementation

### 3.1 Script Setup And Language

- Follow the repository's Options API or Composition API convention. Prefer `<script setup>` for new Composition API components when compatible with nearby code.
- Use `lang="ts"` only in TypeScript projects.
- Define props/emits using pure type annotations:

  ```typescript
  defineProps<{
    title: string;
    isActive?: boolean;
  }>();

  const emit = defineEmits<{
    (event: "update", value: string): void;
  }>();
  ```

### 3.2 State Access

- **Pinia:** Do NOT destructure state directly; it breaks reactivity.
  ```typescript
  const store = useUserStore();
  const { user } = storeToRefs(store); // Correct
  const { login } = store; // Actions are safe to destructure
  ```

### 3.3 CSS & Styling

- Use `<style scoped>`.
- Avoid deep selectors (`::v-deep`) unless absolutely necessary for library overrides.

---

## 4. Implementation Checklist

When writing Vue code, ensure:

- [ ] Is the logic complex? -> Extract to Composable.
- [ ] Is this a new route? -> Use Lazy Loading.
- [ ] Is this a heavy component? -> Use `defineAsyncComponent`.
- [ ] Is this an API mutation? -> Consider Optimistic UI.
- [ ] Are keys unique and stable?

## 5. Required Completion Gate

Before considering frontend work complete:

1. Detect the package manager from the repository lockfile and inspect existing scripts/configuration.
2. Format changed frontend files with the configured formatter. Do not format the whole repository unless required by its script or requested by the user.
3. Run configured lint fixes only against changed files when safely supported, then run the non-mutating lint check.
4. Run configured type checking (`vue-tsc`, `tsc`, or repository equivalent).
5. Run the smallest relevant Vitest/test target, then the production build when compilation or bundling may be affected.
6. Report exact commands and failures. Do not claim completion while required checks fail.

Use official documentation matching installed major versions when repository guidance is absent. Do not upgrade or restructure solely to match newer documentation.
