import { usePage } from "@inertiajs/react";
import {
  Building2,
  ChevronDown,
  ChevronUp,
  Check,
  CircleUser,
  LogOut,
  PanelsTopLeft,
  Settings,
} from "lucide-react";

import {
  Dropdown,
  DropdownButton,
  DropdownDivider,
  DropdownHeading,
  DropdownItem,
  DropdownLabel,
  DropdownMenu,
} from "@/components/ui/dropdown";
import {
  Sidebar,
  SidebarBody,
  SidebarFooter,
  SidebarHeader,
  SidebarItem,
  SidebarLabel,
  SidebarSection,
  SidebarSpacer,
} from "@/components/ui/sidebar";
import { Avatar } from "@/components/ui/avatar";
import type { SharedPageProps } from "@/types/models";

function pathMatches(currentPath: string, href: string, exact = false) {
  if (exact) {
    return currentPath === href;
  }

  return currentPath.startsWith(href);
}

function AccountDropdownMenu() {
  return (
    <DropdownMenu className="min-w-64" anchor="top start">
      <DropdownItem href="/users/settings">
        <CircleUser data-slot="icon" />
        <DropdownLabel>Account settings</DropdownLabel>
      </DropdownItem>
      <DropdownDivider />
      <DropdownItem href="/users/log-out" method="delete">
        <LogOut data-slot="icon" />
        <DropdownLabel>Log out</DropdownLabel>
      </DropdownItem>
    </DropdownMenu>
  );
}

export default function AppSidebar() {
  const {
    url,
    props: {
      auth: { user, organization, organizations },
    },
  } = usePage<SharedPageProps>();

  const currentPath = url.split("?")[0];
  const avatarSeed = `${organization.slug}:${user.email}`;
  const canSwitchOrganizations = organizations.length > 1;

  return (
    <Sidebar>
      <SidebarHeader>
        <div className="mb-3 px-2">
          <p className="text-sm font-semibold tracking-wide text-zinc-950 dark:text-white">
            TemplateApp
          </p>
        </div>

        <SidebarSection>
          <Dropdown>
            <DropdownButton as={SidebarItem}>
              <span className="flex min-w-0 items-center gap-3">
                <span className="flex size-7 items-center justify-center rounded-md bg-white text-zinc-950 ring-1 ring-zinc-200">
                  <Building2 className="size-4" />
                </span>
                <SidebarLabel>{organization.name}</SidebarLabel>
              </span>
              <ChevronDown data-slot="icon" />
            </DropdownButton>

            <DropdownMenu className="min-w-64" anchor="bottom start">
              {canSwitchOrganizations ? <DropdownHeading>Organizations</DropdownHeading> : null}

              {canSwitchOrganizations
                ? organizations.map((candidate) => (
                    <DropdownItem
                      key={candidate.id}
                      href="/org/current"
                      method="put"
                      data={{ organization_id: String(candidate.id) }}
                    >
                      <Building2 data-slot="icon" />
                      <DropdownLabel>{candidate.name}</DropdownLabel>
                      {candidate.id === organization.id ? (
                        <Check className="col-start-5 size-4" />
                      ) : null}
                    </DropdownItem>
                  ))
                : null}

              {canSwitchOrganizations ? <DropdownDivider /> : null}

              <DropdownItem href="/org/settings">
                <Settings data-slot="icon" />
                <DropdownLabel>Organization settings</DropdownLabel>
              </DropdownItem>
            </DropdownMenu>
          </Dropdown>
        </SidebarSection>
      </SidebarHeader>

      <SidebarBody>
        <SidebarSection>
          <SidebarItem href="/" current={pathMatches(currentPath, "/", true)}>
            <PanelsTopLeft data-slot="icon" />
            <SidebarLabel>Dashboard</SidebarLabel>
          </SidebarItem>
        </SidebarSection>

        <SidebarSpacer />
      </SidebarBody>

      <SidebarFooter className="max-lg:hidden">
        <Dropdown>
          <DropdownButton as={SidebarItem}>
            <span className="flex min-w-0 items-center gap-3">
              <Avatar seed={avatarSeed} className="size-10 rounded-full ring-1 ring-zinc-950/10" />
              <span className="min-w-0">
                <span className="block truncate text-sm/5 font-normal text-zinc-950 dark:text-white">
                  {user.name}
                </span>
                <span className="block truncate text-xs/5 font-normal text-zinc-500 dark:text-zinc-400">
                  {user.email}
                </span>
              </span>
            </span>
            <ChevronUp data-slot="icon" />
          </DropdownButton>

          <AccountDropdownMenu />
        </Dropdown>
      </SidebarFooter>
    </Sidebar>
  );
}
