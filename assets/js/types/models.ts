export interface AppUser {
  id: number;
  name: string;
  email: string;
}

export interface AppOrganization {
  id: number;
  name: string;
  slug: string;
  invitations?: AppInvite[];
}

export interface AppOrganizationSwitcherItem {
  id: number;
  name: string;
}

export interface AppInvite {
  id: number;
  email: string;
  role: string;
  status: string;
  inserted_at: string | null;
  expires_at: string | null;
  organization_name?: string | null;
  invited_by_email: string | null;
}

export interface AppOrganizationMember {
  id: number;
  user_id: number;
  name: string;
  email: string;
  role: string;
  joined_at: string;
}

export interface Auth {
  user: AppUser;
  organization: AppOrganization;
  organizations: AppOrganizationSwitcherItem[];
}

export interface FlashMessages {
  success?: string;
  info?: string;
  warning?: string;
  error?: string;
  message?: string;
}

export interface SharedPageProps {
  [key: string]: unknown;

  auth: Auth;
  flash: FlashMessages;
  errors: Record<string, string>;
}

export interface UnauthenticatedPageProps {
  [key: string]: unknown;

  auth: {
    user: AppUser | null;
    organization: AppOrganization | null;
  };
  flash: FlashMessages;
  errors: Record<string, string>;
}
