import type { UnauthenticatedPageProps } from "@/types/models";

declare module "@inertiajs/core" {
  interface InertiaConfig {
    sharedPageProps: Pick<UnauthenticatedPageProps, "auth" | "flash" | "errors">;
    flashDataType: UnauthenticatedPageProps["flash"];
    errorValueType: string;
  }
}

export {};
