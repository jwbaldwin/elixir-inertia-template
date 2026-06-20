import { useEffect, useRef } from "react";

import { Toaster } from "@/components/ui/sonner";
import { toast } from "sonner";

type FlashLevel = "error" | "info" | "message" | "success" | "warning";

export interface FlashMessages {
  error?: string;
  info?: string;
  message?: string;
  success?: string;
  warning?: string;
}

interface FlashToastsProps {
  flash?: FlashMessages;
}

const FLASH_LEVELS: FlashLevel[] = ["error", "warning", "success", "info", "message"];

export default function FlashToasts({ flash }: FlashToastsProps) {
  const lastFlash = useRef<FlashMessages | undefined>(undefined);

  useEffect(() => {
    if (!flash || flash === lastFlash.current) {
      return;
    }

    lastFlash.current = flash;

    for (const level of FLASH_LEVELS) {
      const message = flash[level];

      if (!message) {
        continue;
      }

      switch (level) {
        case "error":
          toast.error(message);
          break;
        case "warning":
          toast.warning(message);
          break;
        case "success":
          toast.success(message);
          break;
        default:
          toast(message);
      }
    }
  }, [flash]);

  return <Toaster closeButton={false} richColors position="bottom-center" />;
}
