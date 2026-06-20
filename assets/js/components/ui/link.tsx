import * as Headless from "@headlessui/react";
import { Link as InertiaLink } from "@inertiajs/react";
import * as React from "react";

type InertiaLinkProps = React.ComponentPropsWithoutRef<typeof InertiaLink>;

export const Link = React.forwardRef<HTMLAnchorElement, InertiaLinkProps>(
  function Link(props, ref) {
    return (
      <Headless.DataInteractive>
        <InertiaLink {...props} ref={ref} />
      </Headless.DataInteractive>
    );
  },
);
