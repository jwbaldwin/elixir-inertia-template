import "./app.css";
import axios from "axios";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import * as React from "react";

import AppLayout from "@/layouts/app-layout";
import AuthLayout from "@/layouts/auth-layout";

axios.defaults.xsrfHeaderName = "x-csrf-token";

interface PageMeta {
  title: string;
  description?: string;
  className?: string;
}

interface PageModule {
  default: React.ComponentType & { layout?: (page: React.ReactNode) => React.ReactNode };
  pageMeta?: PageMeta;
}

createInertiaApp({
  resolve: async (name: string) => {
    const pages = import.meta.glob<PageModule>("./pages/**/*.tsx");
    const importFn = pages[`./pages/${name}.tsx`];
    if (!importFn) {
      throw new Error(`Page not found: ${name}`);
    }
    const page = await importFn();

    // Apply default layouts based on folder path
    // Inertia passes the page element as an argument, not as children
    const DefaultLayout = name.startsWith("app/")
      ? (pageElement: React.ReactNode) => (
          <AppLayout
            title={page.pageMeta?.title ?? "TemplateApp"}
            description={page.pageMeta?.description}
            className={page.pageMeta?.className}
          >
            {pageElement}
          </AppLayout>
        )
      : name.startsWith("public/")
        ? (pageElement: React.ReactNode) => (
            <AuthLayout
              title={page.pageMeta?.title ?? "TemplateApp"}
              description={page.pageMeta?.description}
            >
              {pageElement}
            </AuthLayout>
          )
        : undefined;

    if (page.default.layout || !DefaultLayout) return page.default;

    return Object.assign(page.default, { layout: DefaultLayout });
  },
  setup({ App, el, props }) {
    createRoot(el!).render(<App {...props} />);
  },
});
